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

use Composer\Semver\Semver;
use Doctrine\Common\Inflector\Inflector;
use PhpCsFixer\Console\Application;
use SLLH\StyleCIBridge\StyleCI\Configuration;
use SLLH\StyleCIFixers\Fixers;
use Symfony\Component\Config\Definition\Processor;
use Symfony\Component\Console\Formatter\OutputFormatterStyle;
use Symfony\Component\Console\Output\ConsoleOutput;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Yaml\Yaml;
use Symfony\CS\Finder;
use Symfony\CS\Fixer;
use Symfony\CS\Fixer\Contrib\HeaderCommentFixer;
use Symfony\CS\FixerInterface;

/**
 * @author Sullivan Senechal <soullivaneuh@gmail.com>
 * @author Rob Frawley 2nd <rmf@src.run>
 */
final class ConfigBridge
{
    /**
     * @var string
     */
    const CS_FIXER_MIN_VERSION = '1.6.1';

    /**
     * @var string
     */
    const PRESET_NONE = 'none';

    /**
     * @var OutputInterface
     */
    private $output;

    /**
     * @var FixerFactory
     */
    private $fixerFactory = null;

    /**
     * @var string
     */
    private $styleCIConfigDir;

    /**
     * @var array|null
     */
    private $styleCIConfig = null;

    /**
     * @var string|array
     */
    private $finderDirs;

    /**
     * @param string $rootDirectoryPath
     */
    public function __construct($rootDirectoryPath)
    {
        if (!Semver::satisfies(class_exists('Symfony\CS\Fixer') ? Fixer::VERSION : Application::VERSION, sprintf('>=%s', self::CS_FIXER_MIN_VERSION))) {
            throw new \RuntimeException(sprintf(
                'PHP-CS-Fixer v%s is not supported, please upgrade to v%s or higher.', Fixer::VERSION, self::CS_FIXER_MIN_VERSION
            ));
        }

        $this->styleCIConfigDir = $rootDirectoryPath;
        $this->finderDirs = $rootDirectoryPath;

        $this->output = new ConsoleOutput();
        $this->output->getFormatter()->setStyle('warning', new OutputFormatterStyle('black', 'yellow'));

        $this->parseStyleCIConfig();
    }

    /**
     * @param string $rootDirectoryPath
     *
     * @return \Symfony\CS\Config
     */
    public static function create($rootDirectoryPath): \Symfony\CS\Config
    {
        $bridge = new static($rootDirectoryPath);

        $config = \Symfony\CS\Config::create();

        $config->level(FixerInterface::NONE_LEVEL);
        $config->fixers($bridge->getFixers());

        return $config->finder($bridge->getFinder());
    }

    /**
     * @return \Symfony\CS\Finder
     */
    public function getFinder(): Finder
    {
        $finder = \Symfony\CS\Finder::create()->in($this->finderDirs);

        if (isset($this->styleCIConfig['finder'])) {
            $finderConfig = $this->styleCIConfig['finder'];
            foreach ($finderConfig as $key => $values) {
                $finderMethod = Inflector::camelize($key);
                foreach ($values as $value) {
                    if (method_exists($finder, $finderMethod)) {
                        $finder->$finderMethod($value);
                    } else {
                        $this->output->writeln(sprintf(
                            '<warning>Can not apply "%s" finder option with PHP-CS-Fixer v%s. You fixer config may be erroneous. Consider upgrading to fix it.</warning>',
                            str_replace('_', '-', $key),
                            Fixer::VERSION
                        ));
                    }
                }
            }
        }

        return $finder;
    }

    /**
     * @return string[]
     */
    public function getFixers(): array
    {
        $presetFixers = $this->resolveAliases($this->getPresetFixers());
        $enabledFixers = $this->resolveAliases($this->styleCIConfig['enabled']);
        $disabledFixers = $this->resolveAliases($this->styleCIConfig['disabled']);

        $fixers = array_merge(
            $enabledFixers,
            array_map(function ($disabledFixer) {
                return '-'.$disabledFixer;
            }, $disabledFixers),
            array_diff($presetFixers, $disabledFixers) // Remove disabled fixers from preset
        );

        if (method_exists('Symfony\CS\Fixer\Contrib\HeaderCommentFixer', 'getHeader') && HeaderCommentFixer::getHeader()) {
            array_push($fixers, 'header_comment');
        }

        return $fixers;
    }

    /**
     * Returns fixers converted to rules for PHP-CS-Fixer 2.x.
     *
     * @return array
     */
    public function getRules(): array
    {
        $fixers = $this->getFixers();

        $rules = array();
        foreach ($fixers as $fixer) {
            if ('-' === $fixer[0]) {
                $name = substr($fixer, 1);
                $enabled = false;
            } else {
                $name = $fixer;
                $enabled = true;
            }

            if ($this->isFixerAvailable($name)) {
                $rules[$name] = $enabled;
            } else {
                $this->output->writeln(sprintf('<warning>Fixer "%s" does not exist, skipping.</warning>', $name));
            }
        }

        return $rules;
    }

    /**
     * @return bool
     */
    public function getRisky(): bool
    {
        return $this->styleCIConfig['risky'];
    }

    /**
     * @return string[]
     */
    private function getPresetFixers(): array
    {
        if (static::PRESET_NONE === $this->styleCIConfig['preset']) {
            return array();
        }
        $validPresets = Fixers::getPresets();

        return $validPresets[$this->styleCIConfig['preset']];
    }

    /**
     * Adds both aliases and real fixers if set. PHP-CS-Fixer would not take care if not existing.
     * Better compatibility between PHP-CS-Fixer 1.x and 2.x.
     *
     * @param string[] $fixers
     *
     * @return string[]
     */
    private function resolveAliases(array $fixers): array
    {
        foreach (Fixers::$aliases as $alias => $name) {
            if (in_array($alias, $fixers, true) && !in_array($name, $fixers, true) && $this->isFixerAvailable($name)) {
                array_push($fixers, $name);
            }
            if (in_array($name, $fixers, true) && !in_array($alias, $fixers, true) && $this->isFixerAvailable($alias)) {
                array_push($fixers, $alias);
            }
        }

        return $fixers;
    }

    /**
     * @param string $name
     *
     * @return bool
     */
    private function isFixerAvailable($name): bool
    {
        // PHP-CS-Fixer 1.x BC
        if (null === $this->fixerFactory) {
            return true;
        }

        return $this->fixerFactory->hasRule($name);
    }

    private function parseStyleCIConfig()
    {
        if (null === $this->styleCIConfig) {
            $config = Yaml::parse(file_get_contents(sprintf('%s/.styleci.yml', $this->styleCIConfigDir)));
            $processor = new Processor();
            $this->styleCIConfig = $processor->processConfiguration(new Configuration(), array('styleci' => $config));
        }
    }
}
