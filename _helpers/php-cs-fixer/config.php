<?php

/*
 * This file is part of `src-run/usr-src-builder`
 *
 * (c) Rob Frawley 2nd <rmf@scr.be>
 *
 * For the full copyright and license information, view the LICENSE.md
 * file distributed with this source code.
 */

namespace SR\PhpCsFixer;

use SR\PhpCsFixer\ConfigBridge;
use Symfony\CS\Config as SymfonyConfig;
use Symfony\CS\Fixer\Contrib\HeaderCommentFixer;

class Config
{
    /**
     * @var string
     */
    private $autoload = '/vendor/sllh/php-cs-fixer-styleci-bridge/autoload.php';

    /**
     * @var string
     */
    private $location;

    /**
     * @var string|null
     */
    private $header;

    /**
     * @var string
     */
    private $headerTemplate = <<<EOF
This file is part of the `%s` project.

(c) %s

For the full copyright and license information, please view the LICENSE.md
file that was distributed with this source code.
EOF;

    /**
     * @var string|null
     */
    private $project;

    /**
     * @var string|null
     */
    private $author;

    /**
     * @var bool
     */
    private $linting = true;

    /**
     * @var bool
     */
    private $caching = true;

    /**
     * @param array $options
     */
    public function __construct(array $options)
    {
        $this->setOptions($options);
    }

    /**
     * @return SymfonyConfig
     */
    public function create(): SymfonyConfig
    {
        require $this->locateAutoLoaderFilePath();

        $this->setHeaderCommentString();

        $bridge = $this->getConfigInstance();
        $bridge->setUsingCache($this->caching);
        $bridge->setUsingLinter($this->linting);

        $this->writeLine('Returning configured "%s" instance.', SymfonyConfig::class);

        return $bridge;
    }

    /**
     * @param array $options
     */
    public function setOptions(array $options)
    {
        $this->writeLine('Using configuration options: %s', json_encode($options));

        foreach (['linting', 'caching', 'header', 'autoload', 'project', 'author', 'location'] as $name) {
            if (null !== $value = $options[$name] ?? null) {
                $this->{$name} = $value;
            }
        }

        if (null === $this->location) {
            throw new \InvalidArgumentException('You must set the "location" configuration option.');
        }
    }

    /**
     * @throws \RuntimeException If autoloader cannot be found in current directory or any of it's parents
     *
     * @return string
     */
    private function locateAutoLoaderFilePath(): string
    {
        $autoloadRootPath = realpath(__DIR__);
        $i = 0;

        for (; $i < 100; $i++) {
            if (file_exists($filePath = $autoloadRootPath.$this->autoload)) {
                $this->writeLine('Using autoloader "%s".', $filePath);

                return $filePath;
            }

            if ('/' === $autoloadRootPath) {
                break;
            }

            $autoloadRootPath = realpath($autoloadRootPath.'/../');
        }

        throw new \RuntimeException(sprintf(
            'Unable to locate "%s" in "%s" or its %d parent directories.', $this->autoload, __DIR__, $i - 1
        ));
    }

    /**
     * @return self
     */
    private function setHeaderCommentString(): self
    {
        if (true === $this->header) {
            $this->generateHeaderReplacementArguments();
        }

        if (null === $this->header) {
            $this->generateHeaderCommentString();
        }

        if (null !== $this->header) {
            if (!class_exists(HeaderCommentFixer::class)) {
                throw new \RuntimeException('Unable to set header comment string as "Symfony\CS\Fixer\Contrib\HeaderCommentFixer" class is missing.');
            }

            HeaderCommentFixer::setHeader($this->header);
        }

        return $this;
    }

    /**
     * @return self
     */
    private function generateHeaderReplacementArguments(): self
    {
        $this->writeLine('Using auto generating header replacement arguments.');

        $package = $this->readPackageConfiguration();

        $this->author = $package['pkg_copy'] ?? null;

        if ($package['pkg_name']) {
            if ($package['pkg_orgn']) {
                $this->project = sprintf('%s/%s', $package['pkg_orgn'], $package['pkg_name']);
            } else {
                $this->project = $package['pkg_name'];
            }
        }

        $this->header = null;

        return $this;
    }

    /**
     * @return self
     */
    private function generateHeaderCommentString(): self
    {
        if (null !== $this->project && null !== $this->author) {
            $this->writeLine('Using auto generated header replacement string message.');

            $this->header = vsprintf($this->headerTemplate, [
                $this->project,
                $this->author,
            ]);
        }

        return $this;
    }

    /**
     * @return string
     */
    private function locatePackageConfigurationFile(): string
    {
        $possibleFileNames = ['.bldr.yml', '.bldr.yaml', '.builder.yml', '.builder.yaml', '.sr.yml', '.sr.yaml'];

        foreach ($possibleFileNames as $f) {
            $file = $this->location.DIRECTORY_SEPARATOR.$f;

            if (file_exists($file) && is_readable($file)) {
                $this->writeLine('Using package configuration "%s".', $file);

                return $file;
            }
        }

        throw new \RuntimeException(sprintf(
            'Unable to find package configuration file in "%s" as "%s".', $this->location, implode(':', $possibleFileNames)
        ));
    }

    /**
     * @return array
     */
    private function readPackageConfiguration(): array
    {
        $elements = [];

        foreach (file($this->locatePackageConfigurationFile()) as $line) {
            $elements = array_merge($elements, $this->parseSimpleKeyValueYamlLine($line));
        }

        return $elements;
    }

    /**
     * @param string $line
     *
     * @return array[]
     */
    private function parseSimpleKeyValueYamlLine(string $line): array
    {
        if (1 === preg_match('{^\s*(?<name>[a-z_]+)\s*:\s*"?(?<value>.+?)"?$}i', $line, $matches)) {
            if ($matches['value'] === '~') {
                $matches['value'] = null;
            }

            return [$matches['name'] => $matches['value']];
        }

        throw new \RuntimeException(sprintf('Unable to parse malformed YAML line "%s"', $line));
    }

    /**
     * @return SymfonyConfig
     */
    private function getConfigInstance(): SymfonyConfig
    {
        $this->requireDependency('bridge');

        return ConfigBridge::create($this->location);
    }

    /**
     * @param string $what
     *
     * @return self
     */
    private function requireDependency(string $what): self
    {
        require sprintf('%s/%s.php', __DIR__, $what);

        return $this;
    }

    /**
     * @param string $line
     * @param array  $replacements
     *
     * @return self
     */
    private function writeLine(string $line, ...$replacements): self
    {
        echo sprintf("[%s] %s\n", __CLASS__, vsprintf($line, $replacements));

        return $this;
    }
}
