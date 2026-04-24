## [UNRELEASED] YYYY/MM/DD

## Añadido

## Cambiado

## Deprecado

## Removido

## Arreglado

## Seguridad


**Se debe actualizar la versión en estos archivos:**

- [pubspec.yaml](../pubspec.yaml#L4) Para el correcto versionado de Flutter
- [release_body](release_body.md) Para las notas de release

Para ver las tags actuales y sus mensajes (local)

```shell
git tag -l -n9
```

Serie de comandos para eliminar una tag desde ambos lados, realizar etiquetado, y pushear.
**Esto requiere ya haber creado la commit sin pushear**

```shell
#Cambiar v*.*.* o la versión anterior a la tag actual
git tag -d v*.*.* 
git push origin --delete v*.*.*
git tag -a v*.*.* -m "Inserte mensaje de tag aquí, no usar esto al ser un placeholder, debes cambiar las versiones tambien xddd"
git push --atomic origin main v*.*.*
```
