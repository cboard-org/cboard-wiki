/* Title: Project structure */

## Cboard Structure

```
cboard
|- .circleci/config.yml -> CircleCI job configuration
|- rootfs/etc/nginx/conf.d
    |- default.conf -> Nginx server definition for Cboard
    |- gzip.conf -> Nginx gzip configuration
|- public -> Static assets for Cboard (images, icons, etc.)
|- src
    |- api -> API integration in Cboard
    |- components -> React components (or containers)
    |- providers -> Language, Speech, Theme and Scanner providers for Cboard
    |- translations
        |- src/cboard.json -> JSON file with original keys (with EN translations)
        |- [locale].json -> Translation for <Locale>
        |- ...
    |- i18n.js -> Load translations in APP
    |- reducers.js -> Reducers for Redux
    |- store.js -> Redux store
|- Dockerfile -> Dockerfile for Cboard's docker image
|- package.json -> NPM configuration file
```