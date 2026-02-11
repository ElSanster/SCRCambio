## [UNRELEASED] YYYY/MM/DD

## Añadido

## Cambiado

## Deprecado

## Removido

## Arreglado

## Seguridad


**Se debe actualizar la versión en estos archivos:**

- [release_android.yml](../.github/workflows/release_android.yml#L38)
- [release_windows.yml](../.github/workflows/release_windows.yml#L27) Ambos workflows para el correcto tageo.
- [pubspec.yaml](../pubspec.yaml#L4) Para el correcto versionado de Flutter (Si de casualidad sirve xd)
- [release_body](release_body.md) Para las notas de release

Para ver las tags actuales (local)

```powershell
git tag -l
```

Serie de comandos para eliminar una tag desde ambos lados, realizar etiquetado, y pushear.
**Esto requiere ya haber creado la commit sin pushear**

```powershell
git tag -d v*.*.* #Cambiar a la tag actual
git push origin --delete v*.*.*
git tag -a v*.*.* -m "Inserte nombre chido para el tag"
git push --atomic origin main v*.*.*
```
