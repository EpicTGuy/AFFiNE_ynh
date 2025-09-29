# AFFiNE - Package YunoHost

[![CI](https://github.com/EpicTGuy/AFFiNE_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg)](https://github.com/EpicTGuy/AFFiNE_ynh/actions)
[![Niveau YunoHost](https://img.shields.io/badge/YunoHost-Niveau%206+-green)](https://github.com/EpicTGuy/AFFiNE_ynh/actions)
[![Shellcheck](https://github.com/EpicTGuy/AFFiNE_ynh/workflows/CI%20AFFiNE%20YunoHost/badge.svg?label=shellcheck)](https://github.com/EpicTGuy/AFFiNE_ynh/actions)

*[Lire ce README en anglais.](./README.md)*

> *Ce package vous permet d'installer AFFiNE rapidement et simplement sur un serveur YunoHost.
Si vous n'avez pas YunoHost, regardez [ici](https://yunohost.org/#/install) pour savoir comment l'installer et en profiter.*

## Vue d'ensemble

AFFiNE est un workspace open-source auto-hébergeable qui combine documentation collaborative, whiteboard et gestion de projet. Ce package YunoHost permet d'installer facilement AFFiNE sur votre serveur YunoHost avec une configuration automatique complète.

### Features

- Ut enim ad minim veniam, quis nostrud exercitation ullamco ;
- Laboris nisi ut aliquip ex ea commodo consequat ;
- Duis aute irure dolor in reprehenderit in voluptate ;
- Velit esse cillum dolore eu fugiat nulla pariatur ;
- Excepteur sint occaecat cupidatat non proident, sunt in culpa."


**Version incluse :** 1.0~ynh1

**Démo :** https://demo.example.com

## Captures d'écran

![Capture d'écran de Example app](./doc/screenshots/example.jpg)

## Avertissements / informations importantes

* Any known limitations, constrains or stuff not working, such as (but not limited to):
    * requiring a full dedicated domain ?
    * architectures not supported ?
    * not-working single-sign on or LDAP integration ?
    * the app requires an important amount of RAM / disk / .. to install or to work properly
    * etc...

* Other infos that people should be aware of, such as:
    * any specific step to perform after installing (such as manually finishing the install, specific admin credentials, ...)
    * how to configure / administrate the application if it ain't obvious
    * upgrade process / specificities / things to be aware of ?
    * security considerations ?

## Documentations et ressources

* Site officiel de l'app : <https://example.com>
* Documentation officielle utilisateur : <https://yunohost.org/apps>
* Documentation officielle de l'admin : <https://yunohost.org/packaging_apps>
* Dépôt de code officiel de l'app : <https://some.forge.com/example/example>
* Documentation YunoHost pour cette app : <https://yunohost.org/app_example>
* Signaler un bug : <https://github.com/YunoHost-Apps/example_ynh/issues>

## Informations pour les développeurs

Merci de faire vos pull request sur la [branche testing](https://github.com/YunoHost-Apps/example_ynh/tree/testing).

Pour essayer la branche testing, procédez comme suit.

``` bash
sudo yunohost app install https://github.com/YunoHost-Apps/example_ynh/tree/testing --debug
ou
sudo yunohost app upgrade example -u https://github.com/YunoHost-Apps/example_ynh/tree/testing --debug
```

**Plus d'infos sur le packaging d'applications :** <https://yunohost.org/packaging_apps>
