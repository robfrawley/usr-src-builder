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
    private $location = __DIR__.'/../../../';

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

        return $bridge;
    }

    /**
     * @param array $options
     */
    public function setOptions(array $options)
    {
        foreach (['linting', 'caching', 'header', 'autoload', 'project', 'author', 'location'] as $name) {
            if (null !== $value = $options[$name] ?? null) {
                $this->{$name} = $value;
            }
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
    private function generateHeaderCommentString(): self
    {
        if (null !== $this->project && null !== $this->author) {
            $this->header = vsprintf($this->headerTemplate, [
                $this->project,
                $this->author,
            ]);
        }

        return $this;
    }

    /**
     * @return SymfonyConfig
     */
    private function getConfigInstance(): SymfonyConfig
    {
        require __DIR__.'/bridge.php';

        return ConfigBridge::create($this->location, $this->location);
    }
}
