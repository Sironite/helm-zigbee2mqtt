# Changelog

## [1.4.0](https://github.com/Sironite/helm-zigbee2mqtt/compare/zigbee2mqtt-v1.3.1...zigbee2mqtt-v1.4.0) (2026-06-28)


### Features

* add authentikOutpost support for Zigbee2MQTT frontend SSO ([7818333](https://github.com/Sironite/helm-zigbee2mqtt/commit/781833332cadb84c6e15d1efa8bfcd36bd7b6eb9))
* add config.existingSecret and config.existingConfigMap support ([4b6b7b8](https://github.com/Sironite/helm-zigbee2mqtt/commit/4b6b7b81f7ab35163802411d5196f06e7a260865))
* initial release of zigbee2mqtt Helm chart ([abf4e33](https://github.com/Sironite/helm-zigbee2mqtt/commit/abf4e338bfde9bc6c8ca71f199655d9dd20ddbce))


### Bug Fixes

* copy config via init container so zigbee2mqtt can write to data dir ([5de82b7](https://github.com/Sironite/helm-zigbee2mqtt/commit/5de82b7615eca644559ea86b5cc9bfd2062a1457))
* rename PVC template from data to data-volume for upgrade compatibility ([8038a6b](https://github.com/Sironite/helm-zigbee2mqtt/commit/8038a6b31612a6b0e003eb6462a83f5dd93a8388))


### Reverts

* undo PVC rename, chart stays generic ([4067937](https://github.com/Sironite/helm-zigbee2mqtt/commit/40679378369f338db53c4e4a847dd8749de613e5))

## [1.3.0](https://github.com/Sironite/helm-zigbee2mqtt/compare/zigbee2mqtt-v1.2.1...zigbee2mqtt-v1.3.0) (2026-06-28)


### Features

* add authentikOutpost support for Zigbee2MQTT frontend SSO ([7818333](https://github.com/Sironite/helm-zigbee2mqtt/commit/781833332cadb84c6e15d1efa8bfcd36bd7b6eb9))

## [1.2.1](https://github.com/Sironite/helm-zigbee2mqtt/compare/zigbee2mqtt-v1.2.0...zigbee2mqtt-v1.2.1) (2026-06-23)


### Bug Fixes

* copy config via init container so zigbee2mqtt can write to data dir ([5de82b7](https://github.com/Sironite/helm-zigbee2mqtt/commit/5de82b7615eca644559ea86b5cc9bfd2062a1457))
* rename PVC template from data to data-volume for upgrade compatibility ([8038a6b](https://github.com/Sironite/helm-zigbee2mqtt/commit/8038a6b31612a6b0e003eb6462a83f5dd93a8388))


### Reverts

* undo PVC rename, chart stays generic ([4067937](https://github.com/Sironite/helm-zigbee2mqtt/commit/40679378369f338db53c4e4a847dd8749de613e5))

## [1.2.0](https://github.com/Sironite/helm-zigbee2mqtt/compare/zigbee2mqtt-v1.1.0...zigbee2mqtt-v1.2.0) (2026-06-23)


### Features

* add config.existingSecret and config.existingConfigMap support ([4b6b7b8](https://github.com/Sironite/helm-zigbee2mqtt/commit/4b6b7b81f7ab35163802411d5196f06e7a260865))

## [1.1.0](https://github.com/Sironite/helm-zigbee2mqtt/compare/zigbee2mqtt-v1.0.0...zigbee2mqtt-v1.1.0) (2026-06-23)


### Features

* initial release of zigbee2mqtt Helm chart ([abf4e33](https://github.com/Sironite/helm-zigbee2mqtt/commit/abf4e338bfde9bc6c8ca71f199655d9dd20ddbce))

## [1.0.0](https://github.com/Sironite/helm-zigbee2mqtt/releases/tag/zigbee2mqtt-v1.0.0) (2026-06-23)


### Features

* Initial release
