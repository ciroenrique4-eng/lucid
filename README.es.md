<div align="center">

<img src="assets/logo.svg" width="104" alt="Lucid">

# CirOShell

<p><a href="README.md">English</a> · <b>Español</b></p>

**Construido sobre Lucid Sn3akyy1 v1.10.5**

**Un shell de escritorio Material 3 Expressive para Hyprland, construido sobre [Quickshell](https://quickshell.org).**

Una barra, un dock que se transforma en lanzador, widgets de escritorio, una pantalla de bloqueo,
un selector de emojis, una herramienta de capturas y una aplicación de ajustes, todo con el mismo
tema generado a partir de tu fondo de pantalla.

<p>
  <a href="https://github.com/Sn3akyy1/lucid/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/Sn3akyy1/lucid?style=for-the-badge&label=LAST%20COMMIT&labelColor=14100E&color=FF7F50"></a>
  <a href="https://github.com/Sn3akyy1/lucid/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/Sn3akyy1/lucid?style=for-the-badge&label=STARS&labelColor=14100E&color=FFC46B"></a>
  <a href="https://github.com/Sn3akyy1/lucid/releases"><img alt="Release" src="https://img.shields.io/github/v/tag/Sn3akyy1/lucid?style=for-the-badge&label=RELEASE&labelColor=14100E&color=FFAB91"></a>
  <img alt="Repo size" src="https://img.shields.io/github/repo-size/Sn3akyy1/lucid?style=for-the-badge&label=REPO%20SIZE&labelColor=14100E&color=E8A87C">
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/LICENSE-MIT-80CBC4?style=for-the-badge&labelColor=14100E"></a>
</p>

<p>
  <img alt="Version" src="https://img.shields.io/badge/VERSION-v1.10.5-FF7F50?style=for-the-badge&labelColor=14100E">
  <img alt="Platform" src="https://img.shields.io/badge/PLATFORM-ARCH%20LINUX-FFAB91?style=for-the-badge&logo=archlinux&logoColor=FFAB91&labelColor=14100E">
  <img alt="Compositor" src="https://img.shields.io/badge/COMPOSITOR-HYPRLAND-80CBC4?style=for-the-badge&labelColor=14100E">
  <a href="https://quickshell.org"><img alt="Built on Quickshell" src="https://img.shields.io/badge/BUILT%20ON-QUICKSHELL-FFC46B?style=for-the-badge&labelColor=14100E"></a>
</p>

<img src="assets/prev1.webp" alt="El escritorio de Lucid: la barra en la parte superior, widgets de calendario, clima, reloj y música sobre el fondo de pantalla, y el dock en la parte inferior">

</div>

---

> [!NOTE]
> **Este es un fork.** Lucid es el [proyecto de Sn3akyy1](https://github.com/Sn3akyy1/lucid);
> este fork es lo que uso todos los días: el Lucid original más cada cambio que le
> he enviado como pull request, todo fusionado. Todo lo de aquí se ofrece primero
> al proyecto original, y lo que se acepte allí simplemente desaparece de esta lista.

## Acerca de este fork

La rama `integrated` (la predeterminada aquí) es el último `main` del proyecto original,
con cada uno de mis pull requests abiertos fusionado encima, los conflictos entre ellos
resueltos y unos cuantos commits pequeños que solo tienen sentido una vez que todos
están juntos (sobre todo el redondeo de esquinas de controles que vienen de distintos
pull requests). Se reconstruye cada vez que el original avanza o cambia un pull request,
así que nunca se aleja mucho del propio Lucid.

Para instalarlo en lugar del original, clona esta rama; el resto de este README
se aplica tal cual:

```sh
git clone --branch integrated https://github.com/ciroenrique4-eng/lucid.git
cd lucid
./install.sh
```

Actualizar es lo mismo: `git pull` y `./install.sh`. El aviso de actualización en
Ajustes sigue las versiones del proyecto original, y esta rama también las sigue.

| | Qué añade | Pull request |
| --- | --- | --- |
| **Barra** | Organiza los módulos en tres grupos, arrastrando | [#44](https://github.com/Sn3akyy1/lucid/pull/44) |
|  | Módulos nuevos (privacidad, energía, ventana activa) y aspectos y opciones para cada módulo | [#50](https://github.com/Sn3akyy1/lucid/pull/50) |
|  | Un estilo de ancho completo, apertura al pasar el cursor y ocultado automático | [#16](https://github.com/Sn3akyy1/lucid/pull/16) |
|  | Una barra en cada pantalla | [#14](https://github.com/Sn3akyy1/lucid/pull/14) |
|  | La barra en el borde inferior: todos los paneles, ventanas emergentes, menús y notificaciones se abren hacia arriba | solo este fork |
|  | Un módulo Apps: las apps ancladas al dock y todas las abiertas, con un icono cada una, vistas previas en vivo, y para cambiar, abrir y cerrar desde la barra | solo este fork |
|  | Fondos de módulo en la barra completa, y grupos de módulos que se unen en la disposición | solo este fork |
|  | Muescas compartidas: los módulos unidos en la disposición cuelgan de una sola muesca, así que las muescas tienen distintos anchos | solo este fork |
|  | Botones Inicio y Mostrar escritorio, arrastrar para reordenar las apps, contadores de notificaciones en sus iconos | solo este fork |
|  | Aspectos del centro de control: apilado, ancho (cifras, mosaicos y dos controles deslizantes altos lado a lado), compacto y mínimo | solo este fork |
|  | Preajustes de barra: Lucid, barras de tareas centradas y clásicas, barra superior y dock, mínimo; un toque, con deshacer | solo este fork |
|  | Ajustes de Lucid es una app propia: su nombre e icono en docks y barras de tareas, y una entrada en el lanzador | solo este fork |
| **Lanzador** | Un solo ranking para ventanas, apps, comandos y la web; botones de energía a tu elección | [#17](https://github.com/Sn3akyy1/lucid/pull/17) |
|  | Aplicaciones favoritas y ocultas, y una página propia en Ajustes | [#32](https://github.com/Sn3akyy1/lucid/pull/32) |
|  | Un panel de vista previa para el portapapeles, tipos de entrada, limpieza desde el teclado | [#10](https://github.com/Sn3akyy1/lucid/pull/10) |
| **Ajustes** | Busca en todas las páginas desde el riel | [#34](https://github.com/Sn3akyy1/lucid/pull/34) |
|  | Una página Ventanas para Hyprland: aspecto, mosaico y comportamiento | [#46](https://github.com/Sn3akyy1/lucid/pull/46) |
|  | Una página Entrada: distribuciones de teclado, ratón y touchpad, gestos | [#47](https://github.com/Sn3akyy1/lucid/pull/47) |
|  | Espacios de trabajo especiales: desenfoque detrás, un margen como el de una tarjeta, y los tuyos propios | [#45](https://github.com/Sn3akyy1/lucid/pull/45) |
|  | Un control para decidir qué tan redondo es todo el shell | [#18](https://github.com/Sn3akyy1/lucid/pull/18) |
|  | Sonido: medidores de nivel, balance, prueba de canales, ajustes de WirePlumber, un clic por cada paso de volumen | [#11](https://github.com/Sn3akyy1/lucid/pull/11) |
|  | Todo el shell en tu idioma: español por ahora, Automático sigue al sistema, cambia en vivo, y otro idioma es un archivo JSON | solo este fork |
| **Color** | Las plantillas siguen cada paleta, no solo el fondo de pantalla, se generan una a una con un registro | [#36](https://github.com/Sn3akyy1/lucid/pull/36) |
|  | Una página Colores: paletas generadas y las plantillas de apps | [#38](https://github.com/Sn3akyy1/lucid/pull/38) |
|  | Una página Paletas: una galería de esquemas base16/base24, temas desde un archivo, un editor y exportación | [#40](https://github.com/Sn3akyy1/lucid/pull/40) |
| **Uso diario** | Luz nocturna mediante hyprsunset, a mano o con horario | [#53](https://github.com/Sn3akyy1/lucid/pull/53) |
|  | Una tarjeta de vista previa en la esquina después de cada captura o grabación | [#52](https://github.com/Sn3akyy1/lucid/pull/52) |
|  | Un aviso rápido para lo que copias: el texto, un enlace, una muestra de color o la miniatura de una imagen; los secretos permanecen ocultos | solo este fork |
|  | Comparte una red Wi-Fi guardada como código QR | [#51](https://github.com/Sn3akyy1/lucid/pull/51) |
|  | OSD: un estilo de muesca, un nivel arrastrable, la retroiluminación del teclado, bloqueos de teclas como avisos | [#22](https://github.com/Sn3akyy1/lucid/pull/22) |
|  | Sonidos de respuesta: un clic para el brillo como el del volumen, y sonidos al conectar y desconectar, bloquear, vaciar la papelera y hacer capturas; varios de cada uno para elegir, o un archivo propio | solo este fork |
|  | Widget de teléfono: explora sus archivos, botones según los plugins y un segundo teléfono | [#15](https://github.com/Sn3akyy1/lucid/pull/15) |
|  | Recibir archivos por Bluetooth, con Aceptar y Rechazar en una notificación | solo este fork |
|  | Las ventanas fijadas llevan un borde propio, una pestaña en la esquina que las desfija, y una onda al fijarlas | solo este fork |
|  | Una ventana que pide atención recibe una pestaña con una campana sonando en su esquina, y una onda la primera vez que la ves | solo este fork |
|  | Iconos de escritorio: la carpeta Escritorio sobre el fondo de pantalla, compartiendo espacio con los widgets (un icono se aparta ante uno, incluso a mitad de arrastre); arrastra archivos hacia dentro, hacia fuera, a carpetas y a la papelera, renombra en el lugar | solo este fork |
| **Correcciones** | Capturas y grabaciones desde la pantalla en la que estás | [#8](https://github.com/Sn3akyy1/lucid/pull/8) |
|  | El emparejamiento Bluetooth conserva su clave (pairable se mantiene activo durante el emparejamiento) | [#9](https://github.com/Sn3akyy1/lucid/pull/9) |
|  | Funcionan los avisos de cargador y batería baja, y Vista previa se ejecuta | [#25](https://github.com/Sn3akyy1/lucid/pull/25) |
|  | La tarjeta de disco cuenta los volúmenes LVM y LUKS | [#27](https://github.com/Sn3akyy1/lucid/pull/27) |
|  | El reloj de 12 horas muestra AM/PM también fuera del inglés | [#29](https://github.com/Sn3akyy1/lucid/pull/29) |
|  | Cerrar sesión funciona con una configuración de Hyprland en Lua | [#30](https://github.com/Sn3akyy1/lucid/pull/30) |
|  | El instalador solo ofrece reiniciar cuando el shell realmente está en ejecución | [#7](https://github.com/Sn3akyy1/lucid/pull/7) |

¿Encontraste un error en alguno de estos? Abre un issue aquí. Para cualquier otra cosa, corresponde
al [proyecto original](https://github.com/Sn3akyy1/lucid/issues).

---

> **v1.1.0: pantalla de bloqueo, polkit, cuentas y modo claro.** Es lo que uso
> a diario. Todo lo que llegó en esta versión, y en cada una anterior, está en el
> [registro de cambios](CHANGELOG.md). Todavía puede haber asperezas y los reportes
> de errores son bienvenidos.

> **Para enterarte de nuevas versiones**, pulsa **Watch → Custom → Releases** en la
> parte superior de esta página. Lucid también lo comprueba por sí mismo: una vez al día
> pregunta a GitHub por la última versión y lo avisa una sola vez, en una notificación.
> Consulta [Actualizar](#actualizar).

## Instalación

Lucid se instala en `~/.config/quickshell` y requiere **Arch Linux** y
**Hyprland**. Tres comandos:

```sh
git clone --branch integrated https://github.com/ciroenrique4-eng/lucid.git
cd lucid
./install.sh
```

Eso es todo: el instalador hace el resto:

1. **Revisa tu sistema**: se niega a ejecutarse donde no pueda terminar el trabajo,
   en lugar de dejarte a medio instalar.
2. **Instala dependencias**: busca `paru` o `yay` y lo usa, recurriendo a `pacman`
   para los paquetes de los repositorios. Lista todo y pregunta antes de tocar
   tu sistema. Si dices que no, continúa y te indica qué funciones no van a funcionar.
   Esto incluye las apps que Lucid trae ancladas al dock: varios GB, sobre todo
   del AUR. `--no-apps` las omite.
3. **Copia el shell** a `~/.config/quickshell`, moviendo antes cualquier configuración
   existente a `~/.config/quickshell.backup-<marca de tiempo>`.
4. **Configura Hyprland**: `hyprland.lua` y sus módulos: los atajos, las reglas de
   ventanas y capas, el desenfoque, las animaciones y un autoinicio que lanza el shell
   al iniciar sesión. Si ya tienes una configuración, se respalda y se te pregunta
   primero; `--no-hypr` deja la tuya intacta.
5. **Configura el tema**: las paletas, el hook del fondo de pantalla y la plantilla
   de matugen. Un `matugen/config.toml` existente se amplía, nunca se reemplaza.
6. **Aplica el aspecto**: los colores de kitty, su opacidad y su shell fish, el prompt
   starship (conectado en `.bashrc`, `.zshrc` y `config.fish`), el tema Matugen de
   VSCode/VSCodium, y el tema GTK: `adw-gtk3-dark` con los iconos FairyWren, escrito
   en `gsettings` y en los `settings.ini` de `gtk-3.0` y `gtk-4.0`.
   `--no-look` lo omite.
7. **Ancla el dock**: lee tus archivos `.desktop` instalados y ancla las apps reales,
   así el dock nunca es una fila de mosaicos vacíos con una letra.
8. **Ofrece reiniciar** una instancia en ejecución con los archivos nuevos.

Después recarga Hyprland para que los nuevos atajos y reglas surtan efecto:

```sh
hyprctl reload
```

O cierra sesión y vuelve a entrar, lo que también aplica el autoinicio. Para iniciar
el shell a mano mientras tanto, ejecuta `qs`.

Elige un fondo de pantalla en **Ajustes → General** la primera vez: eso es lo que
genera tu paleta de colores.

### Actualizar

Haz pull y vuelve a ejecutar. Tus ajustes, apps ancladas, recordatorios, historial de
Shazam y claves de API se trasladan a la nueva instalación:

```sh
git pull
./install.sh
```

Lucid te avisa cuando hay algo que descargar. Una vez al día consulta la API pública de
GitHub por la última versión, y cuando es más nueva que la que instalaste publica una
notificación, una sola vez por versión, nunca otra vez por la misma. La petición es un
simple `curl` a `api.github.com/repos/Sn3akyy1/lucid/releases/latest` y no lleva nada
sobre ti ni sobre tu equipo; **Ajustes → Acerca de** muestra lo que encontró y permite
desactivarlo.

```sh
qs ipc call updates status   # lo que sabe
qs ipc call updates check    # preguntar ahora
```

### Versiones anteriores

`v0.57 beta` es una etiqueta (tag), así que se queda exactamente donde está:

```sh
git clone --branch v0.57 https://github.com/Sn3akyy1/lucid.git
```

También está en la [página de releases](https://github.com/Sn3akyy1/lucid/releases),
como archivo de código fuente. Nada se traslada entre las dos: v1.0.0 cambió lo
suficiente como para que valga la pena instalar desde cero.

### Opciones del instalador

| Opción | Qué hace |
| --- | --- |
| `--no-theming` | Omite la capa de paletas. Deja en paz `~/.config/lucid` y `~/.config/matugen`; úsala si ya tienes una configuración de matugen que no quieres tocar. |
| `--no-hypr` | Conserva tu configuración de Hyprland. No se instalan los atajos, reglas de ventana, desenfoque ni autoinicio de Lucid. |
| `--no-apps` | No instala las apps que el dock trae ancladas (Zen, VSCodium, Spotify, Vesktop, Files, Steam, Proton VPN). El dock ancla entonces los equivalentes que ya tengas. |
| `--no-look` | No toca `kitty.conf`, `starship.toml`, tus archivos rc del shell, los ajustes de VSCode, ni el tema e iconos de GTK. |
| `--no-wallpapers` | No copia los fondos de pantalla incluidos a `~/Pictures/wallpapers`. Pesan ~180 MB, así que conviene usarla con un disco pequeño o una conexión lenta. |
| `--with-hypr` | Reinstala la configuración de Hyprland de Lucid aunque ya haya una instalada. |
| `--skip-deps` | Nunca instala paquetes, solo informa de lo que falta. |
| `-y`, `--yes` | Acepta todas las preguntas. |

Volver a ejecutar el instalador es la forma de actualizar. Mueve tu
`~/.config/quickshell` existente a `~/.config/quickshell.backup-<marca de tiempo>`,
instala los nuevos archivos del shell y luego traslada a ellos tus ajustes, apps
ancladas, recordatorios, historial de Shazam y claves de API. No se borra nada, y la
copia de respaldo se queda donde está hasta que la quites.

## Atajos de teclado

El instalador los incluye en `~/.config/hypr/modules/binds.lua`, junto con las reglas
de ventanas, el desenfoque, las animaciones y el autoinicio. Ejecuta `hyprctl reload`
después de instalar para aplicarlos.

| Tecla | Acción |
| --- | --- |
| `SUPER` (toque) | Lanzador |
| `SUPER` + `P` | Paleta de comandos |
| `SUPER` + `T` | Selector de tema |
| `SUPER` + `B` | Selector de fondo de pantalla |
| `SUPER` + `SHIFT` + `V` | Historial del portapapeles |
| `SUPER` + `S` | Ajustes |
| `SUPER` + `.` | Selector de emojis |
| `SUPER` + `K` | Teclado en pantalla |
| `SUPER` + `W` | Vista general de espacios de trabajo (también: deslizar con tres dedos) |
| `SUPER` + `D` / `Print` | Captura de una región |
| `SUPER` + `Print` | Captura de pantalla completa |
| `SUPER` + `SHIFT` + `T` | Copiar texto de una región (OCR) |
| `SUPER` + `SHIFT` + `C` | Tomar un color de la pantalla |
| `SUPER` + `E` | Archivos |
| `SUPER` + `C` | Cerrar ventana |
| `SUPER` + `V` | Alternar flotante |
| `SUPER` + `1`–`0` | Cambiar de espacio de trabajo (`+SHIFT` mueve la ventana) |
| `SUPER` + `SHIFT` + `S` | Scratchpad, o guarda el espacio de trabajo especial que esté visible |
| `SUPER` + `ALT` + `S` | Guarda la ventana enfocada en el scratchpad, o la devuelve |
| `SUPER` + `SHIFT` + `M` | Espacio de trabajo de música |
| `SUPER` + `SHIFT` + `D` | Espacio de trabajo de comunicaciones |
| `SUPER` + `SHIFT` + `R` | Espacio de trabajo de tareas pendientes |
| `CTRL` + `SHIFT` + `Esc` | Espacio de trabajo del monitor del sistema |
| `SUPER` + flechas | Mover el foco |
| `SUPER` + `R` | Recargar Hyprland |
| `F1`–`F6` | Volumen, micrófono, brillo |
| `F9` | Terminal |
| `F10` | Bloquear |
| `F12` | Calculadora |

¿Lo ejecutaste con `--no-hypr`, o quieres asignar tus propios atajos? Todo está
expuesto mediante IPC:

```
bind = SUPER, SPACE,  exec, qs ipc call -- launcher toggle
bind = SUPER, E,      exec, qs ipc call -- moji toggle
bind = SUPER, L,      exec, qs ipc call -- lock lock
bind = SUPER, S,      exec, qs ipc call -- snap toggle
bind = SUPER SHIFT, T, exec, qs ipc call -- snap text
bind = SUPER SHIFT, C, exec, qs ipc call -- snap color
bind = SUPER, comma,  exec, qs ipc call -- settings open
```

Los espacios de trabajo especiales son Lua de Hyprland, no IPC. Si tienes una
configuración en Lua propia, copia `support/hypr/modules/specials.lua` a
`~/.config/hypr/modules/` y asigna sus funciones como lo hace el `modules/binds.lua`
de Lucid:

```lua
local specials = require("modules.specials")
hl.bind("SUPER + SHIFT + M", specials.toggle("music"))
```

Conserva el `--`. Solo es estrictamente necesario cuando la llamada recibe un
argumento: `qs ipc call settings show bar` falla con *"The following argument was not
expected: bar"*, mientras que `qs ipc call -- settings show bar` funciona. No hace
daño en llamadas sin argumentos, así que usarlo siempre te ahorra sorpresas.

## Qué incluye

### Barra

Seis módulos, cada uno una píldora que se expande en un panel. Cada uno se puede
desactivar en Ajustes.

- **Espacios de trabajo**: vistas previas en vivo de las ventanas de cada espacio, clic
  para cambiar. Los scratchpads (espacios de trabajo especiales) aparecen junto a los
  puntos como una ficha atenuada marcada con un glifo de lo que hay guardado en ellos:
  una terminal para una terminal, una nota para un editor, según las propias categorías
  de cada app. Al abrir uno, los puntos se hunden, los glifos se abren en abanico y se
  elevan con el acento junto a su nombre. Haz clic en un glifo para saltar a esa ventana,
  o arrastra ventanas hacia dentro y fuera desde la fila de scratchpads de la vista general
- **Medios**: controles MPRIS, barra de búsqueda, carátula e identificación de canciones
  estilo Shazam (`songrec`)
- **Bandeja**: bandeja del sistema SNI con menús contextuales que funcionan
- **Reloj**: calendario, clima y recordatorios que aparecen cuando vencen
- **Notificaciones**: agrupadas por aplicación, con respuesta en línea para apps de chat
  y barras de progreso para transferencias. Las nuevas se apilan bajo la barra, la más
  reciente creciendo desde la propia píldora; no molestar las retiene
- **Sistema**: volumen, brillo, batería, estadísticas de disco y un mosaico Caffeine,
  además de paneles completos de Wi-Fi y Bluetooth y un selector de salida y entrada de
  audio. La luna junto al brillo es la **luz nocturna**: calienta la pantalla mediante
  hyprsunset, con transiciones suaves, a mano o de la puesta al amanecer del sol donde
  estés (calculado localmente, sin red) o entre horas que fijes. La flecha junto a ella
  elige qué tan cálida y cuándo; Ajustes → Pantallas tiene lo mismo. Activarla o
  desactivarla mientras corre un horario se mantiene hasta que el horario cambie de
  nuevo. Pasa el cursor sobre cualquier icono de la tira compacta y se nombra solo

Dos formas, que se eligen en Ajustes: **isla** (píldoras redondeadas flotantes) o
**muesca** (pegada al borde de la pantalla, con ensanchamientos que se funden con él).

<img src="assets/prev4.webp" alt="El panel Sistema: interruptores, controles deslizantes, medios y estadísticas del sistema">

*La píldora Sistema se abre como un centro de control: Wi-Fi y Bluetooth con paneles
completos detrás, interruptores rápidos como Caffeine y No molestar, brillo y volumen
con los dispositivos de audio detrás, lo que se está reproduciendo, y CPU, RAM, batería
y uso por disco.*

### Dock y lanzador

Una barra de herramientas M3 flotante que crece hasta convertirse en el lanzador en
lugar de abrir una segunda ventana encima. Apps ancladas, indicadores de ventanas en
ejecución, arrastrar para reordenar, magnificación opcional y ocultado automático.

El lanzador es un solo campo de búsqueda con seis modos:

| Modo | Qué hace |
| --- | --- |
| Apps | Búsqueda difusa sobre entradas `.desktop`: acierta tanto con límites de palabra como con iniciales, así que `vsc` encuentra Visual Studio Code |
| Comandos | Comandos de shell y acciones de shell |
| Tema | Cambia entre las siete paletas incluidas y las que hayas importado |
| Fondo de pantalla | Carrusel de tu carpeta de fondos |
| Energía | Bloquear, cerrar sesión, suspender, reiniciar, apagar, hibernar |
| Portapapeles | Lo que copiaste antes, imágenes incluidas: elige uno para volver a ponerlo en el portapapeles |

Escribe `=` en el campo de búsqueda para una calculadora (`=2^3^2`, asociativa por la
derecha).

Sus opciones tienen una página propia, **Ajustes → Lanzador**: qué tan ancho se abre y
cuántos resultados muestra, qué encuentra una búsqueda, los botones de energía, el
historial del portapapeles y las aplicaciones que marcaste con estrella u ocultaste.

El modo Portapapeles guarda lo que copias y te lo devuelve: elige una entrada para
volver a ponerla en el portapapeles, `Supr` (o el botón de la fila) para quitar una, y
*Borrar historial* en la página Lanzador de Ajustes para quitarlo todo. Las imágenes
también se guardan y se previsualizan en la fila. `cliphist` es el almacén; el shell es
dueño de los observadores `wl-paste` que lo alimentan, así que el historial registra
mientras el shell esté en ejecución. Desactiva todo con el interruptor de la página
Lanzador.

<img src="assets/prev2.webp" alt="El carrusel de fondos de pantalla dentro del lanzador">

*Modo Fondo de pantalla: un carrusel que se previsualiza mientras te mueves por él, y
aplica con la segunda pulsación.*

### Widgets de escritorio

Tarjetas que colocas tú mismo sobre el fondo de pantalla. Abre **Ajustes → Widgets**,
haz clic en un mosaico y aterriza en el escritorio; arrástralo donde quieras, fíjalo
para que deje de moverse, y vuelve donde lo dejaste tras reiniciar.

<img src="assets/prev5.webp" alt="Widgets de reloj, calendario, tareas y nota sobre un fondo de lago, con la ventana emergente de volumen sobre el dock">

*Un reloj, el mes, una lista de tareas y una nota adhesiva, con la ventana emergente
de volumen sobre el dock y un visualizador funcionando debajo.*

Once tipos, treinta y tres aspectos entre ellos: cada categoría trae varias variantes
de los mismos datos:

| Widget | Aspectos |
| --- | --- |
| Reloj | Digital, apilado, analógico, mínimo (sin tarjeta), reloj mundial con tres ciudades |
| Calendario | Mes completo, esta semana, hoy |
| Sistema | Medidores de arco, barras, una gráfica de dos minutos, o una simple fila de números: CPU, memoria, disco y temperatura |
| Batería | Anillo, celda, o el detalle completo con tiempo restante y consumo |
| Medios | Tarjeta con carátula, fila compacta, o carátula con los controles encima |
| Visualizador | Barras, bandas en espejo, o una sola onda rellena, en vivo con lo que suene. Arrastra cualquier borde para darle tamaño, incluso a todo lo ancho de la pantalla |
| Clima | Ahora, un pronóstico de cuatro días, o un icono y un número, para el lugar fijado en Fecha y hora |
| Notas | Un cuadrado adhesivo o una hoja rayada, guardada mientras escribes |
| Tareas | Una lista de verificación o solo lo que sigue pendiente |
| Paleta | Los roles de Material con los que está construido el shell ahora; haz clic en uno para copiar el hex |
| Teléfono | Tarjeta, fila compacta o un control remoto: batería e intensidad de señal del teléfono emparejado, con timbrar, ping, enviar un archivo y enviar el portapapeles a un clic; el control remoto maneja lo que el teléfono esté reproduciendo |

Cada widget tiene su propio menú (clic derecho, o el engranaje que aparece al pasar el
cursor) para su estilo, su tamaño y sus propias opciones: 12 o 24 horas, qué métricas
mostrar, °C o °F, el tinte de una nota, etc. La mayoría admite uno de cuatro tamaños;
el visualizador, en cambio, muestra un contorno con tiradores al pasar el cursor, y
arrastras cualquier borde o esquina hasta la forma que quieras.

Al arrastrar, se ajusta a los bordes y líneas centrales de la pantalla y se alinea con
los demás widgets, con guías mientras arrastras. Pueden ir en cualquier parte de la
pantalla, incluidas las franjas que reservan la barra y el dock: un visualizador de
ancho completo escondido bajo el dock es justamente la idea. Los widgets quedan **debajo**
de tus ventanas por defecto para comportarse como un escritorio, y se apartan ante las
ventanas a pantalla completa; ambos son interruptores en la página Widgets si prefieres
que floten encima.

### Espacios de trabajo especiales

Scratchpads que se deslizan sobre el espacio de trabajo en el que estés, y se ocultan
de nuevo con las mismas teclas.

| Teclas | Espacio de trabajo | Abre |
| --- | --- | --- |
| `SUPER` + `SHIFT` + `S` | Scratchpad | Nada propio: un lugar donde aparcar ventanas |
| `SUPER` + `SHIFT` + `M` | Música | Spotify, Feishin, Supersonic, Cider, YouTube Music, TIDAL… |
| `SUPER` + `SHIFT` + `D` | Comunicaciones | Discord, Vesktop, Telegram, Signal, Element, Slack… |
| `SUPER` + `SHIFT` + `R` | Tareas | Todoist, Planify, Errands, Endeavour, Obsidian… |
| `CTRL` + `SHIFT` + `Esc` | Sistema | btop en una terminal, Mission Center, Resources… |

Una tecla inicia la app de su espacio de trabajo si no está en ejecución, y la trae de
vuelta si la moviste a otro lugar; al abrirla desde el lanzador o el dock, la app también
aterriza en su espacio de trabajo. `SUPER` + `ALT` + `S` guarda la ventana enfocada en el
scratchpad y, si se pulsa dentro de un espacio de trabajo especial, la devuelve. La tecla
del scratchpad también guarda el espacio de trabajo que esté visible, así que una sola
tecla siempre te devuelve a lo que estabas haciendo.

**Ajustes → Espacios de trabajo** elige las apps de cada uno, desactiva cualquiera de
ellos, y fija cuánto se atenúa la pantalla de detrás, si también se desenfoca, cuánto
margen conservan las ventanas respecto a los bordes de la pantalla y si cambiar de
espacio de trabajo los guarda. *Nuevo espacio de trabajo* crea uno propio, con un nombre,
una marca para la barra y cualquier app; su tecla va a `keybinds.json` como cualquier
otra, así que aparece en la hoja de atajos y se cambia en la página Atajos. Eliminarlo
devuelve sus ventanas al espacio de trabajo en el que estés.
*Añadir una app* ofrece todo lo instalado, no solo el catálogo anterior, y deduce por qué
identificar su ventana. Escribe `~/.config/hypr/lucid-specials.lua`, que
`modules/specials.lua` lee en cada pulsación de tecla, así que un cambio se aplica sin
recargar Hyprland.

### Ventanas

**Ajustes → Ventanas** cambia cómo Hyprland dibuja tus ventanas, en vivo, con una vista
previa dibujada con los valores vigentes: los espacios entre ventanas y alrededor de la
pantalla, el ancho y color del borde (ninguno, el acento de tu paleta, o un degradado
entre tres de sus colores, que sigue al tema cuando cambia), un borde tenue en las demás
ventanas, qué tan redondas son las esquinas y su forma, una sombra y atenuar las ventanas
en las que no estás. En *Mosaico*: la distribución (dwindle, master o scrolling) y las
opciones propias de cada una (hacia dónde divide dwindle y dónde va una ventana nueva, el
lado y tamaño del master, el ancho de una columna de scrolling), con una vista previa de
toda la pantalla para una a cinco ventanas, y un interruptor que lleva una ventana sola de
borde a borde, sin espacios, borde ni esquinas redondeadas. En *Comportamiento*: si el
foco sigue al cursor o espera un clic, si una app puede tomar el foco cuando lo pide, que
el cursor salte con el foco, redimensionar una ventana por sus bordes, ventanas flotantes
que se pegan entre sí y a la pantalla, ocultar el cursor al escribir o tras un rato, y las
animaciones de ventana.

Solo lo que cambies ahí es de Lucid. Va a `~/.config/hypr/lucid-settings.lua`, que
`modules/settings.lua` aplica sin recargar; todo lo demás se queda como lo tiene tu
configuración de Hyprland, y el restablecer de cada fila devuelve su opción a tu
configuración. `hyprland.lua` requiere el módulo antes que cualquier cosa tuya, así que un
archivo que añadas después (`hypr-user.lua`, el `hyprland-gui` de HyprMod) sigue ganando:
la fila indica qué archivo fija la opción y permanece cerrada hasta que se quite allí.

### Entrada

**Ajustes → Entrada** contiene el lado del teclado de Hyprland, mediante el mismo
`lucid-settings.lua` que la página Ventanas y con la misma regla de que gana tu propia
configuración: tus distribuciones en orden (la primera es con la que arranca cada
teclado), cada una elegida por nombre de la lista de distribuciones y variantes del
sistema, la tecla que cambia entre ellas, qué hace Bloq Mayús (las demás opciones de
teclado que fija tu configuración se conservan), el retardo y la velocidad de repetición
de teclas, y Bloq Num al iniciar sesión, con un campo para probarlo todo. Luego el
ratón: velocidad del puntero, aceleración, desplazamiento natural, velocidad de
desplazamiento, botones para zurdos; y, cuando hay uno, el touchpad: tocar para hacer
clic, desplazamiento natural, velocidad de desplazamiento, desactivado al escribir, clic
derecho con dos dedos, tocar y arrastrar, y clic central con ambos botones; y el
deslizamiento entre espacios de trabajo: cuánto recorren los dedos, en qué dirección,
con qué rapidez un gesto rápido cambia de todos modos, cuánto avance basta al soltar para
cambiar, pasarse del vecino y crear un espacio de trabajo nuevo al final.

### Todo lo demás

- **Usuarios y cuentas**: la tarjeta en la parte superior del riel de Ajustes abre una
  página *Usuarios y cuentas* para cada cuenta del equipo: nombre completo, nombre de
  usuario, tipo de cuenta, shell de inicio de sesión, correo y ubicación, con las
  salvaguardas que importan: el último administrador no puede degradarse a sí mismo y una
  cuenta con sesión iniciada no puede renombrarse. Fija una contraseña o haz que la propia
  cuenta la elija en el siguiente inicio de sesión, añade y elimina cuentas, activa grupos
  suplementarios y elige una imagen entre los rostros incluidos o cualquier imagen. Todo
  pasa por AccountsService, así que el propio diálogo polkit del shell es quien pregunta y
  nada se ejecuta como root
- **Historial de imágenes de cuenta**: al cambiar la imagen de tu cuenta se conserva la
  anterior en un estante del selector, de la más nueva a la más antigua, así que cualquier
  imagen que hayas usado está a un clic. Guarda doce u 8 MB, descarta las más antiguas a
  medida que llegan nuevas, no archiva nada dos veces y se puede vaciar por completo
- **Solicitudes de autenticación**: Lucid es el agente polkit de la sesión, así que cada
  petición de administrador en el equipo aparece en el diálogo propio del shell en lugar
  del de KDE. polkitd y PAM siguen siendo el backend; el diálogo nombra la acción, muestra
  la contraseña de qué cuenta pide (con la imagen de la página Usuarios) y te deja elegir
  otro administrador cuando polkit acepte más de uno
- **Pantalla de bloqueo**: un auténtico `WlSessionLock` que verifica la contraseña
  mediante PAM, dispuesto como Material You dispone una pantalla de bloqueo: un reloj
  sobredimensionado de dos líneas en el color propio del fondo de pantalla, el clima, la
  batería, la red y el Bluetooth de un vistazo, lo que se está reproduciendo, las
  notificaciones y una barra de energía que pregunta antes de cerrar sesión. Empieza a
  escribir y se enfoca: el fondo se desenfoca más y todo menos la tarjeta de inicio de
  sesión pasa a segundo plano. Cuenta tus intentos restantes según faillock, avisa de
  Bloq Mayús, muestra la distribución del teclado y no deja que una notificación inicie
  nada mientras está activa
- **Pantalla de inicio de sesión**: la pantalla de bloqueo portada a SDDM, para que el
  equipo se vea como él mismo antes de iniciar sesión: el mismo reloj, la misma paleta y el
  mismo fondo, desenfocado una sola vez de antemano en lugar de en una GPU en frío, con los
  selectores de usuario y sesión donde van los chips de vistazo. Se pinta con los colores
  del propio shell en ejecución, así que sigue un cambio de tema. El instalador la copia
  cuando SDDM está presente pero nunca cambia a ella: qué tema te recibe sigue siendo
  decisión tuya
- **Teclado en pantalla**: `SUPER` + `K`, el menú del clic derecho del escritorio o la
  lista de comandos del lanzador. Nunca quita el foco de donde estás escribiendo, y los
  clics fuera de él llegan a la aplicación de debajo, así que el cursor de texto se queda
  donde lo pusiste. Una capa de letras y una de funciones, modificadores que se enganchan
  con una pulsación y se bloquean con dos, y combinaciones enviadas como combinaciones.
  Arrástralo a donde quieras por la franja de su parte superior y ahí se queda
- **Selector de emojis**: emojis, kaomojis y GIFs (Giphy o Tenor), con recientes,
  favoritos y variantes de tono de piel; pega en la ventana enfocada
- **Capturas de pantalla**: selección de región, pantalla completa y grabación de pantalla
  con micrófono y audio del sistema opcionales. Lo que capturaste flota después en la
  esquina como una tarjeta: haz clic para abrirla, arrástrala directamente a un chat o a
  un gestor de archivos, o copia, marca, muéstrala en su carpeta o envíala a la papelera.
  Se desliza fuera tras unos segundos, o se queda mientras el puntero reposa sobre ella;
  una grabación recibe la misma tarjeta con un fotograma del video. General → Capturas
  cambia la tarjeta por la notificación de siempre, o por nada
- **Copiador de texto**: el modo *Texto* en la barra de herramientas de capturas. Arrastra
  un recuadro sobre cualquier cosa en pantalla (una imagen, un fotograma de video, un PDF,
  un diálogo de error, una ventana que no te deja seleccionar su texto) y las palabras
  que haya dentro llegan a tu portapapeles. Pasa el recorte por tesseract dos veces, una
  invertido, y se queda con la mejor lectura, así que el texto claro sobre fondo oscuro de
  una interfaz funciona tan bien como un escaneo. Los emojis también pasan: tesseract no
  tiene ninguno en su conjunto de caracteres y o los descarta o los lee como letras
  basura, así que todo lo colorido y cuadrado se compara con los glifos de tus fuentes de
  emoji instaladas. Un solo color plano significa texto, muchos significan emoji. Una forma
  que no sabe nombrar se omite en lugar de adivinarse. Leer toma un momento, así que la
  superposición no desaparece al soltar: la barra de herramientas, la sombra y el recuadro
  que dibujaste se quedan, y un haz recorre la selección hasta que el texto está en el
  portapapeles, momento en que se cierra sola. El resultado llega como un aviso bajo la
  barra y no como una notificación de escritorio
- **Selector de color**: el modo *Color* delega en `hyprpicker`. Al elegirlo se quitan el
  congelado, la sombra y la mira y se dejan pasar los clics, así que la barra de
  herramientas queda flotando sobre un escritorio vivo y utilizable. Elige HEX, RGB o HSL y
  luego pulsa el cuentagotas: la barra de herramientas se queda sobre hyprpicker, haces
  clic en un píxel, y el valor se copia y se muestra en un aviso con el color al lado. La
  plantilla de salida se fija por formato, así que la lupa, el portapapeles y el aviso
  leen lo mismo y los tres son CSS válido (`#RRGGBB`, `rgb(r, g, b)`,
  `hsl(h, s%, l%)`). Cancelar la selección te deja en la barra de herramientas; elegir un
  color termina la sesión. El aviso muestra el color como tal y no como un icono.
  hyprpicker recibe componentes en bruto y la cadena se construye aquí, así que la muestra,
  el portapapeles y el formato concuerdan
- **Avisos (toasts)**: una píldora compacta bajo la barra para cosas que solo necesitan
  decirse. Cualquier script puede lanzar uno: `qs ipc call -- toast show game "Game Mode On"`,
  o `toast warn alert "..."` para la variante roja. Los iconos con nombre son `copy`,
  `check`, `alert`, `info`, `text`, `game` y `camera`; cualquier otro se toma como una
  ruta SVG en bruto
- **Notificaciones**: una página *Notificaciones* para su comportamiento: si aparecen
  ventanas emergentes, cuánto dura una y si una aplicación puede fijar su propio tiempo,
  cuánto del mensaje y cuántos botones de acción se muestran, no molestar con horas
  silenciosas entre dos horarios y una regla para ventanas a pantalla completa, un sonido
  de notificación con su propio volumen, cuántas conserva la lista, silenciado por
  aplicación, e interruptores para agrupar por aplicación, mostrar hace cuánto llegó cada
  una, barras de progreso, respuesta en línea y cuántas ventanas emergentes se apilan a la
  vez
- **OSD**: volumen, brillo y micrófono, cada uno una insignia y un nivel; Bloq Mayús y
  Bloq Num también tienen uno, que muestra las letras que hará la siguiente pulsación
  (`ABC` contra `abc`) en lugar de las palabras activado y desactivado
- **Escritorio**: arrastra sobre el escritorio vacío y un recuadro de acento translúcido
  sigue al cursor, como en Windows y macOS; es cosmético y no selecciona nada. Clic derecho
  en el escritorio para fondo de pantalla, tema, tus widgets colocados, una captura y
  ajustes. Ambos son interruptores en la página General
- **Fecha y hora**: una página *Fecha y hora* en Ajustes guarda dónde cree el shell que
  está. Activa **Detectar ubicación automáticamente** (el mismo interruptor que el mosaico
  GPS del panel del sistema en la barra) y tu posición se lee de tu conexión de red cada
  pocas horas; déjalo desactivado y nombra una ciudad tú mismo. Se obtiene un pronóstico
  para esa posición de [Open-Meteo](https://open-meteo.com) y lo comparten el reloj de la
  barra, la pantalla de bloqueo y el widget de clima, así que los tres nunca pueden
  discrepar. La zona horaria de esa página es la **de la máquina**, no una privada: elegir
  una zona ejecuta `timedatectl set-timezone` tras un aviso de polkit, así que todas las
  aplicaciones del equipo se mueven juntas y Lucid nunca puede desfasarse del resto de tu
  escritorio. Activa *Fijarla según mi ubicación* y una nueva posición trae consigo la
  zona. Un programa lee la zona una vez al iniciarse, así que lo que ya esté abierto se
  queda en la zona anterior hasta que lo reinicies; Lucid lo corrige por sí mismo y acierta
  en ambos casos
- **Red**: una página *Red* que cubre lo que NetworkManager puede hacer. Radio Wi-Fi, una
  lista de redes en vivo agrupada en conectadas, guardadas y cercanas, con filtro, un
  escaneo que puedes detener, unirse por red con contraseña, olvidar y unirse
  automáticamente, y un formulario para redes ocultas. **Compartir** en una red guardada
  la muestra como un código QR al que se une la cámara de un teléfono, con la contraseña al
  lado, con puntos hasta que la pidas y copiada sin pasar al historial del portapapeles; el
  panel Wi-Fi de la barra tiene el mismo código tras un botón. Debajo: dispositivos
  cableados con velocidad de enlace, perfiles de VPN y WireGuard para conectar y
  desconectar, un punto de acceso Wi-Fi para compartir la conexión y todos los perfiles
  guardados con su interruptor de conexión automática. Cada dispositivo también recibe su
  direccionamiento (IPv4, IPv6, puerta de enlace, DNS, MAC, MTU, velocidad de enlace) y un
  editor de **configuración IP** que alterna entre DHCP y una dirección, puerta de enlace y
  DNS fijados a mano, o solo reemplaza el DNS dejando el resto automático. Se puede
  automatizar con `qs ipc call network status | list | rescan`
- **Sonido**: una página *Sonido* para lo que suena y lo que escucha. Cada salida y cada
  entrada que tiene el equipo, cada una con su nombre, con lo que está haciendo ahora (su
  modo y la toma por la que sale el sonido) y una marca en la que está en uso. Haz clic en
  otra y toma el relevo; todo lo que ya estaba sonando se muda con ella, que es la parte
  que suele faltar. Abre un dispositivo para ver su propio volumen, su **toma** (altavoces,
  la salida de auriculares, la salida digital, con las desconectadas indicadas como
  desconectadas) y su **modo**, el perfil de tarjeta que decide qué dispositivos ofrece.
  Debajo, todo lo que produce o recibe sonido ahora mismo: un volumen y un silenciado
  propios por programa, y un dispositivo propio, de modo que una aplicación puede sonar en
  otro lado mientras el resto se queda quieto. Un visualizador o un grabador de pantalla
  sobre un monitor se deja donde está en lugar de arrastrarlo a un micrófono. Lee PipeWire
  directamente y se entera de los cambios al instante, así que concuerda con `pavucontrol`
  y con lo que uses. Se puede automatizar con `qs ipc call settings sound`
- **Bluetooth**: una página *Bluetooth* en Ajustes es un gestor completo: la radio, la
  visibilidad, si el equipo acepta solicitudes de emparejamiento y el nombre que ven los
  demás dispositivos. Debajo, cada dispositivo que el adaptador conoce, agrupado en
  conectados, emparejados y disponibles, con filtro, un escaneo que se detiene solo tras un
  minuto y, por dispositivo: conectar, emparejar, olvidar, renombrar, reconexión
  automática, permitir despertar, bloquear y batería cuando el dispositivo la reporta.
  Unos auriculares conectados reciben además su **modo de audio** (alta calidad frente a
  manos libres, según los perfiles que PipeWire ofrezca) para que cambiar al micrófono ya
  no implique un viaje a `pavucontrol`. **Recibir archivos**: un teléfono o portátil que
  envía algo por Bluetooth recibe una notificación con Aceptar y Rechazar; una vez
  aceptado, la misma notificación sigue la transferencia y la última abre el archivo o lo
  muestra en su carpeta. Elige la carpeta (Descargas por defecto) y si los dispositivos
  emparejados se saltan la pregunta
- **Teléfono**: una página *Teléfono* que es un auténtico cliente de KDE Connect, no un
  lanzador del de otro. Maneja el demonio de KDE Connect por D-Bus, así que empareja,
  desempareja y responde solicitudes de emparejamiento con la clave de verificación
  mostrada en ambos lados. Abre un dispositivo conectado y obtienes: **enviar archivos**
  mediante el selector de archivos del propio escritorio, enviar texto o un enlace,
  hacerlo sonar, bloquearlo, montar y explorar su almacenamiento, enviar tu portapapeles,
  ejecutar los comandos que configuraste en él, sus **notificaciones** con descartar y
  respuesta en línea, un **control remoto de medios** con búsqueda y volumen para el
  reproductor que esté usando, **su** volumen del sistema, y un **touchpad y teclado** que
  manejan el teléfono desde este equipo. Cada función por dispositivo se puede desactivar
  individualmente. También automatizable: `qs ipc call kdeconnect status`, `list`,
  `rescan`, y `qs ipc call -- kdeconnect ring <id>`
- **Inactividad y suspensión**: una página *Inactividad* que se encarga de hypridle por
  ti. Escribe `~/.config/hypr/hypridle.conf` y reinicia el demonio cada vez que algo en la
  página cambia, así que la escalera (atenuar, bloquear, apagar pantalla, suspender) se
  fija con controles deslizantes en lugar de a mano. Un riel en la parte superior de la
  página muestra la secuencia en el orden en que se dispara realmente y avisa cuando dos
  pasos están desordenados. Extras que conviene conocer: **mantener despierto**, un
  interruptor cafeína que retiene cada paso hasta que lo apagues; **no interrumpir lo que
  está sonando**, que consulta a playerctl antes de cada paso; una suspensión que puede
  limitarse a batería; y bloquear antes de dormir más despertar la pantalla al reanudar.
  Lo que hubiera en tu hypridle.conf al principio se lee una vez en la página y se copia a
  `hypridle.conf.pre-lucid`, así que no se pierde nada. Automatizable con
  `qs ipc call idle status | keepawake | on | off | restart`
- **Entorno**: una página *Entorno* que se encarga del aspecto del escritorio fuera del
  shell. Tema, tamaño y sombra del cursor, tema de iconos, tema GTK, claro u oscuro, el
  estilo de Qt y las fuentes de interfaz, aplicación, documento y monoespaciada. La
  *sombra del puntero* no tiene un interruptor del compositor detrás (la sombra está
  pintada en las propias imágenes del tema de cursor), así que desactivarla vuelve a
  renderizar el tema desde sus fuentes vectoriales en
  `~/.local/share/icons/<tema>-noshadow`, copiando exactamente los tamaños, puntos de
  acción y retardos de fotograma del original, y apunta todo a esa copia. La idea es que
  una elección llegue a todas partes: cada cambio se escribe en GTK 2, 3 y 4, en
  `gsettings`, en el tema XCursor de respaldo, en qt5ct y qt6ct, y en el módulo env de
  Hyprland, y se ejecuta `hyprctl setcursor` para que el puntero cambie bajo tu mano en
  lugar de en el siguiente inicio de sesión. El dock recoge un nuevo tema de iconos en el
  momento en que lo eliges (Qt solo lee el tema de iconos cuando arranca un proceso, así
  que Lucid recorre los directorios del tema por sí mismo). Solo se tocan las claves que
  Lucid posee: cada comentario y cada otro ajuste de esos archivos se queda donde estaba, y
  un toolkit que este equipo no usa se omite en lugar de inventarse. Empieza leyendo lo que
  el equipo ya dice, así que abrir la página no cambia nada; **Releer del sistema** vuelve
  a recoger esos valores después de que hayas cambiado el aspecto con otra herramienta.
  Desactiva GTK, Qt o Hyprland individualmente si prefieres llevar uno a mano.
  Automatizable con `qs ipc call settings environment`
- **Pantallas**: una página *Pantallas* para las pantallas en sí: resolución, frecuencia de
  actualización, escala, orientación y sincronización adaptativa, una tarjeta por salida,
  que nombra el panel y su tamaño y dice qué está haciendo ahora. Solo se ofrecen los modos
  que la pantalla realmente reporta, así que no hay forma de elegir uno que no pueda
  mostrar, y cada escala se etiqueta con el espacio que deja a las ventanas, con una
  advertencia en las que no dividen el panel de forma exacta. Con más de una pantalla se
  añade una disposición que arrastras: las pantallas se pegan a los bordes de sus vecinas
  para que el puntero no tenga huecos por los que caer, y mover una fija todas donde ya
  están en lugar de dejar que Hyprland reordene el resto. Una pantalla puede reflejar a
  otra o apagarse, salvo la última encendida, que ni la página ni el módulo de Hyprland
  dejarán soltar. El shell en sí (la barra, el dock, la ventana emergente de volumen y los
  avisos) va en la pantalla que elijas, y los widgets sin pantalla propia la siguen; la
  barra y el dock pueden enviarse cada uno a su propia pantalla si prefieres separarlos. El
  fondo de pantalla y el menú del escritorio se dibujan en todas de todos modos, y también
  la pantalla de bloqueo, aunque solo la pantalla en la que está el shell lleva el campo de
  contraseña; las demás muestran el reloj. Si desconectas la pantalla a la que estaba
  fijado, se mueve a una que quede sin perder la elección, así que al volver a conectarla
  regresa. Todo se convierte en reglas de monitor en `~/.config/hypr/lucid-monitors.lua`,
  aplicadas sin recargar, y una pantalla se identifica por su descripción y no por su
  puerto, así que mover el cable conserva lo que fijaste. Automatizable con
  `qs ipc call settings displays`, y la pantalla en la que está el shell con
  `qs ipc call -- displays shell <nombre|here|next|auto>`; vale la pena asignarle un atajo
  si te mueves entre pantallas
- **Cristal (Glass)**: una página *Glass* con un control deslizante para cuánto se
  transparenta el escritorio a través de lo que tiene delante, y una lectura de dónde
  queda. Tres superficies lo siguen, cada una hasta donde puede: los paneles del propio
  shell, kitty (cuyo `background_opacity` deja el texto en paz, así que puede llegar hasta
  el final) y las ventanas de apps, una cuarta parte de lo anterior, porque Hyprland
  desvanece el texto de una ventana junto con su fondo. Cualquier app instalada puede
  escarcharse por separado, y cualquier otra que tengas abierta puede añadirse por su clase
  de ventana. Los valores por app se convierten en reglas de ventana de Hyprland en
  `~/.config/hypr/lucid-glass.lua`, aplicadas sin recargar y empujadas a las ventanas que
  ya están abiertas. Automatizable con `qs ipc call settings glass`
- **Ajustes**: una interfaz gráfica para todo lo anterior, sin editar archivos de
  configuración. Diecisiete páginas tras un riel plegable, tarjetas de lista agrupada, una
  barra de app que se contrae al desplazarte y una flecha de restablecer en todo lo que
  hayas movido de su valor por defecto. El campo de búsqueda a la cabeza del riel encuentra
  cualquier opción por su nombre o su descripción y abre su página desplazada hasta ella;
  `Ctrl+F`, o simplemente empieza a escribir. Automatizable con
  `qs ipc call -- settings search <palabras>`

<img src="assets/prev6.webp" alt="La pantalla de bloqueo de Lucid: un reloj grande a la izquierda, y la tarjeta de inicio de sesión, la canción en reproducción y las notificaciones a la derecha">

*La pantalla de bloqueo: el reloj en el color propio del fondo de pantalla, el clima,
la batería, la red y el Bluetooth de un vistazo, las notificaciones y la barra de
energía en la esquina.*

<img src="assets/prev3.webp" alt="La aplicación de ajustes de Lucid en la página General">

*Ajustes en la página General: la forma de la barra y el dock, el cristal, y qué tanto
se tiñen el acento y las superficies. El riel agrupa las páginas en Apariencia,
Escritorio y Dispositivos.*

## Temas

Los colores vienen de una de ocho paletas, elegida en Ajustes o con el modo Tema del
lanzador:

**Matugen** y **Pywal** generan una paleta a partir de tu fondo de pantalla actual.
**Tu color** construye una a partir de un solo color que eliges y deja el fondo de
pantalla en paz. **Catppuccin Mocha**, **Gruvbox**, **Nightfox**, **Nord** y
**Tokyo Night** son paletas fijas que no cambian con el fondo de pantalla. Todo lo que
importes se suma a ellas, y toda la lista se puede arrastrar al orden que quieras.

Cada paleta tiene también un modo claro: **Claro u oscuro** en la página Tema. Matugen y
Pywal vuelven a extraer el fondo de pantalla en el modo que elijas, Tu color se construye
de nuevo a partir de su color; las paletas fijas obtienen una versión clara construida con
sus propios colores, así que Nord cae en su propio Snow Storm y Gruvbox en su propio
crema. Un esquema claro importado va al revés: el modo claro lo conserva exactamente como
lo hizo su autor, y su modo oscuro se construye con sus propios colores. Las superficies
claras llevan un rastro del acento, y *Tinte del acento* en la página General fija cuánto.
El modo se recuerda junto al tema, y las aplicaciones GTK y Qt lo siguen, cambiando a la
contraparte clara u oscura de su tema donde haya una instalada.

**Paletas generadas**, en la parte superior de **Ajustes → Colores**, da forma a lo que
construyen Matugen y Tu color:

- **Tu color**: el color mismo: escrito en hex, tomado de cualquier parte de la pantalla
  (con `hyprpicker`), o uno de un puñado para empezar.
- **Estilo**: los nueve tipos de esquema de matugen, desde el sereno *Tonal* que usa por
  defecto pasando por *Vibrant*, *Expressive* y *Fidelity* hasta *Neutral* y *Monochrome*.
- **Contraste**: de −100 % a +100 %; 0 es el diseño tal como está especificado.
- **Color del fondo de pantalla**: Matugen parte del color más dominante del fondo de
  pantalla. Esto muestra los otros que encuentra (hasta cuatro), cada uno como el acento
  que daría, para partir de él en su lugar. La elección pertenece a ese fondo: si cambias
  la imagen, vuelve a partir del más dominante.

Los cambios se aplican según los haces, al shell y a cada plantilla de app.

<img src="assets/prev7.webp" alt="Lucid en modo claro: widgets, barra y dock verde pálido sobre una calle nocturna">

*Modo claro, con la paleta tomada del fondo de pantalla. La barra, el dock y cada widget
la siguen.*

Sea cual sea la activa, el shell lee `~/.cache/quickshell/matugen.json`: un mapa plano de
roles de color de Material 3. Cambiar el fondo de pantalla a través de Lucid ejecuta
`~/.config/hypr/scripts/wallpaper/set-wallpaper.sh`, que fija el fondo y luego regenera ese
archivo si el tema activo se deriva del fondo de pantalla.

Todas las pantallas reciben la misma imagen, recortada para llenar. Para tratar una de
forma distinta (una pantalla vertical que deba encuadrarse en lugar de recortarse, o una
segunda pantalla con su propia imagen), pon una regla en
`~/.config/lucid/wallpaper-outputs.conf`, una salida por línea:

```
DP-3      --resize fit --fill-color 000000
HDMI-A-1  ~/Pictures/wallpapers/second.jpg
```

Cualquier argumento que sea un archivo se convierte en la imagen de esa salida; el resto
se pasa a `awww`/`swww`. Las salidas sin regla conservan el fondo que elegiste, y los
colores se siguen generando a partir de ese. `qs ipc call displays list` imprime tus
salidas, de izquierda a derecha.

Si ya usas matugen, el instalador **añade** su plantilla de Quickshell a tu `config.toml`
y respalda el original; tus plantillas existentes no se tocan.

Cada plantilla de `~/.config/matugen/config.toml` sigue a la paleta activa, no solo a las
del fondo de pantalla: elegir Nord o Catppuccin las renderiza con los colores de ese tema.
Eso hace de la configuración el lugar para dar tema a cualquier otra aplicación: pon una
plantilla en `~/.config/matugen/templates/` y añade un bloque para ella:

```toml
[templates.myapp]
input_path = '~/.config/matugen/templates/myapp.css'
output_path = '~/.config/myapp/colors.css'
post_hook = 'pkill -USR1 myapp'   # opcional: avisa a la app que recargue
```

Las plantillas usan la [sintaxis de matugen](https://github.com/InioX/matugen):
`{{colors.primary.default.hex}}` y similares. Una paleta fija rellena cada rol que define
con su propio color; los pocos que no define (la familia `*_fixed`, las paletas tonales,
base16) vienen de un esquema que matugen deriva de su primario. Cada plantilla se renderiza
por separado, así que una que falla no retiene a las demás: un aviso la nombra, y
`~/.cache/lucid/templates.json` guarda lo que pasó con cada plantilla en el último cambio,
con el error de matugen para las que fallaron. `~/.config/lucid/render-templates.sh` es lo
que las renderiza, tanto para el fondo de pantalla como para las paletas fijas.

**Ajustes → Colores** (`qs ipc call settings colours`) muestra lo mismo sin abrir el
archivo:

- **Plantillas de apps** lista cada plantilla con el archivo que escribe y cómo fue el
  último cambio, con la razón de matugen incluida cuando una falló. Un interruptor
  desactiva una plantilla (su bloque queda en la configuración, comentado) o la vuelve a
  activar, en cuyo caso se renderiza al instante con los colores actuales. *Renderizar de
  nuevo* rehace todas sin tocar el fondo de pantalla.
- **Añadir una app** ofrece las plantillas que Lucid incluye para aplicaciones que tienes
  instaladas pero que aún no están conectadas (instaladas después de Lucid, por ejemplo).
- **Tu propia plantilla** añade una desde un archivo o un enlace `https://`. *Probar*
  muestra lo que escribe con tus colores, o por qué no puede, antes de añadirla. Debajo,
  cada rol de color de la paleta actual: haz clic en uno para copiar la variable que lo
  escribe, como `#rrggbb`, `rrggbb`, `rgb()`, `rgba()` o `hsl()`.

`~/.config/lucid/templates.py` se encarga de la edición, y también se ejecuta desde una
terminal (`templates.py list`, `set <nombre> on|off`, `add`, `remove`, `try`). La
configuración se copia a `config.toml.lucid-backup` antes de cada cambio.

### Añadir tu propio tema

**Ajustes → Paletas** (`qs ipc call settings palettes`) tiene una **galería** de los
varios cientos de esquemas base16 y base24 que
[tinted-theming](https://github.com/tinted-theming/schemes) recopila, cada uno dibujado en
sus propios colores, con búsqueda, y dividido en oscuros y claros. *Descargar* trae toda la
colección una vez (cerca de medio megabyte, guardada en `~/.cache/lucid/schemes`); después,
al pasar el cursor sobre un esquema se ofrece *Añadir*, que lo convierte en uno de tus
temas, y *Usar*, que además cambia a él.

La misma página acepta la URL de cualquier repositorio de esquemas de color, o un archivo
de esquema que ya tengas, lo clona o lo lee y construye una paleta completa de Material 3 a
partir de lo que encuentra. Los repositorios de esquemas no concuerdan en ningún formato
común, así que la detección es escalonada: el YAML de base16 y base24, el JSON con claves
por nombre (Catppuccin y similares) y las paletas que Lucid exportó se leen con exactitud,
y todo lo demás recurre a recolectar códigos hex y ordenarlos por tono y croma. Un
repositorio con varias variantes las lista para que elijas una, y los fondos de pantalla
del repositorio vienen con él.

Nada del repositorio se ejecuta jamás: solo se analiza texto y solo se copian imágenes.

Escribe `~/.config/lucid/themes/<id>/{quickshell.json,meta.json}` y
`~/Pictures/wallpapers/<id>/`, que también puedes hacer a mano: un `quickshell.json` con
las mismas claves que las paletas incluidas es todo lo que es un tema. El importador
también se ejecuta desde una terminal, sobre la URL de un repositorio o un archivo o
carpeta local:

```sh
python3 ~/.config/lucid/add-theme.py <url-del-repo|archivo|carpeta> [--list] [--variant <nombre>] [--name <etiqueta>]
python3 ~/.config/lucid/scheme-gallery.py update    # la galería, descargada e indexada
```

Más abajo en la página, el **editor** trabaja sobre la paleta en pantalla. Seis colores
clave (fondo, texto, primario, secundario, terciario, error) reconstruyen cada uno toda la
paleta como se construye un esquema importado, y cualquier otro rol se puede fijar por sí
solo; el shell viste el borrador mientras trabajas, y *Guardar como tema* lo conserva
(*Descartar*, o cerrar Ajustes, devuelve la paleta). **Exportar** escribe la paleta en
pantalla a un archivo: una *paleta de Lucid*, que conserva cada rol y se importa de vuelta
con exactitud, o *YAML de base16* para las herramientas de tinted-theming y cualquier cosa
que lea base16.

El exportador también se ejecuta desde una terminal:

```sh
python3 ~/.config/lucid/palette-edit.py export ~/.cache/quickshell/matugen.json <lucid|base16> <archivo> [<nombre>]
```

## Requisitos

Arch Linux y Hyprland. El instalador se encarga de todo esto; se lista aquí para que
sepas qué se está instalando.

**Obligatorios**: el shell no arranca sin ellos:

`quickshell` · `qt6-5compat` · `qt6-declarative` · `qt6-multimedia`

**Por función**: uno que falte solo rompe su propia función:

| Paquete | Respalda |
| --- | --- |
| `matugen`, `jq` | Colores derivados del fondo de pantalla, cambio de tema |
| `git` | Importar un tema desde un repositorio de esquemas en Ajustes → Tema |
| `awww` | Fijar el fondo de pantalla |
| `python-pywal` | El tema Pywal |
| `networkmanager` | Panel Wi-Fi |
| `qrencode` | El código QR que comparte una red Wi-Fi guardada. Sin él la contraseña se sigue mostrando, sin código |
| `bluez`, `bluez-utils` | Panel Bluetooth y la página de ajustes de Bluetooth |
| `bluez-obex`, `python-gobject` | Recibir archivos por Bluetooth. Sin `bluez-obex` la página lo dice y los archivos enviados al equipo se rechazan |
| `kdeconnect`, `python-gobject` | La página KDE Connect. El demonio es el backend y se inicia solo; `python-gobject` respalda el puente por el que Lucid habla con él. Sin alguno de los dos la página lo dice y no hace nada más |
| `libpulse`, `wireplumber` | Volumen, dispositivos de audio |
| `brightnessctl`, `upower` | Brillo, batería |
| `hyprsunset` | Luz nocturna. Lucid lo inicia cuando la luz nocturna se activa por primera vez y habla con él por `hyprctl hyprsunset`; uno que ya ejecutes se usa tal cual, y nunca se restablece a menos que Lucid lo haya calentado |
| `hypridle` | La página Inactividad: atenuar, bloquear, apagar pantalla y suspender cuando te alejas. Sin él la página lo dice y no escribe nada |
| `grim`, `wf-recorder`, `ffmpeg`, `imagemagick` | Capturas y grabación |
| `tesseract`, `tesseract-data-eng` | El OCR del modo Texto. Sin ellos el modo Texto lo dice y no copia nada. Añade `tesseract-data-<idioma>` y fija `ocrLang` en `lucidshot/Screenshot.qml` para otro idioma |
| `python-pillow`, `python-numpy`, `python-fonttools` | Emojis en el texto copiado. Sin ellos el texto se copia igual, menos los emojis. El atlas de glifos se construye una vez y se guarda en `~/.cache/lucidshot-ocr`; `lucidshot/emoji-ocr.py --atlas` lo construye de antemano para que la primera copia no sea lenta |
| `wl-clipboard`, `wtype` | Pegado de emojis y GIFs |
| `cliphist` | Historial del portapapeles. Sin él el modo Portapapeles del lanzador lo dice y el interruptor de la página Lanzador queda gris |
| `cava` | Visualizadores de audio: la tira del panel de medios (su configuración se instala en `~/.config/cava/quickshell.conf`; la tira necesita los ajustes de salida raw-ascii de ese archivo) y el widget de escritorio, que escribe su propio `~/.cache/quickshell/lucid-cava.conf` con el número de bandas que pida la tarjeta más ancha |
| `songrec` | Identificación de canciones |
| `curl` | Clima, búsqueda de ubicación y búsqueda de GIFs |
| `polkit` | Cada aviso de administrador. El shell se registra como agente de autenticación de la sesión y maneja el ayudante setuid propio de polkit, así que no hace falta otro agente, y ningún otro debe iniciarse, porque solo uno puede ocupar la sesión |
| `accountsservice` | La página Usuarios y cuentas. Cada cambio pasa por él, así que el propio diálogo polkit del shell pregunta y nada se ejecuta como root |
| `libnotify` | Acciones de notificación |
| `swappy` | Marcar una captura, desde su tarjeta de vista previa o notificación |
| `hyprpicker` | El modo Color. Sin él el modo lo dice y no toma nada |
| `xdg-utils` | Abrir enlaces y archivos desde el shell |
| `librsvg` | Desactivar la sombra del puntero: el tema de cursor se renderiza de nuevo desde sus fuentes vectoriales |
| `noto-fonts-emoji` | Renderizado de emojis |

**La configuración de Hyprland y el aspecto**: se instalan a menos que pases `--no-hypr`
o `--no-look`. Los atajos llaman a estos, así que uno que falte es una tecla muerta:

| Paquete | Respalda |
| --- | --- |
| `kitty` | Terminal (`F9`), y los colores temáticos de la terminal |
| `fish` | El shell que abre kitty |
| `nautilus` | Archivos (`SUPER`+`E`) |
| `playerctl` | Las teclas multimedia |
| `gnome-calculator` | Calculadora (`F12`) |
| `starship` | El prompt |
| `ttf-jetbrains-mono-nerd` | Los glifos con los que se dibujan el prompt y kitty |
| `adw-gtk-theme` | Provee `adw-gtk3-dark`, el tema GTK que Lucid selecciona |
| `papirus-icon-theme` | Iconos de respaldo: FairyWren declara `Inherits=Papirus` |

**Los anclajes por defecto del dock**: se instalan a menos que pases `--no-apps`. Varios
GB, sobre todo del AUR:

`zen-browser-bin` · `vscodium-bin` · `spotify` · `vesktop` · `nautilus` ·
`steam` · `proton-vpn-gtk-app`

Todo lo que ya tengas con un equivalente se deja en paz: `vscodium` cuenta por
`vscodium-bin`, `discord` por `vesktop`, y así. `steam` se omite a menos que el
repositorio `multilib` esté habilitado.

Lucid usa APIs específicas de Hyprland para espacios de trabajo y gestión de ventanas. No
funcionará en otros compositores.

### Fuentes

La fuente de interfaz por defecto es **Google Sans**, que no está en los repositorios de
Arch. Si no la tienes, Qt recurre a tu sans por defecto y todo sigue funcionando; o elige
cualquier fuente instalada en Ajustes → General.

## Configuración opcional

La **búsqueda de GIFs** necesita una clave gratuita de Giphy (solo correo, sin tarjeta) de
[developers.giphy.com](https://developers.giphy.com/dashboard/). Ponla en
`~/.config/quickshell/lucidmoji/config.json`:

```json
{ "giphyKey": "tu-clave-aqui", "tenorKey": "", "gifDir": "" }
```

Tenor también sirve si lo prefieres. Los emojis y kaomojis no necesitan clave.

Los **fondos de pantalla** están por defecto en `~/Pictures/wallpapers`, una carpeta por
tema: `~/Pictures/wallpapers/gruvbox` es lo que muestra la tira mientras estás en Gruvbox.
El instalador pone un conjunto en cada una, omitiendo cualquier archivo que ya tengas, y
`--no-wallpapers` deja la carpeta totalmente en paz. Cambia la carpeta en
Ajustes → General, lo que se aplica entonces a todos los temas.

## Referencia de IPC

Cada superficie es automatizable. `qs ipc call -- <objetivo> <función> [argumento]`:

| Objetivo | Funciones |
| --- | --- |
| `launcher` | `toggle` `open` `close` `wallpaper` `theme` `power` `blur` `command` `shuffle` `clipboard` `search <consulta>` |
| `settings` | `toggle` `open` `close` `show <página>` `general` `users` `glass` `bar` `dock` `launcher` `environment` `input` `displays` `widgets` `windows` `workspaces` `notifications` `sound` `network` `bluetooth` `kdeconnect` `idle` `datetime` `font` `reset` |
| `idle` | `status` `keepawake` `awake` `normal` `on` `off` `restart` |
| `network` | `status` `list` `rescan` |
| `nightlight` | `toggle` `on` `off` `status` |
| `kdeconnect` | `status` `list` `rescan` `ring <id>` `ping <id>` `clipboard <id>` `files <id>` `send <id> <ruta>` |
| `widgets` | `add <tipo> <variante>` `remove <uid>` `clear` `toggle` `lock` `unlock` `list` `catalogue` `settings` `resize <uid> <ancho> <alto>` |
| `moji` | `toggle` `open` `close` `emoji` `kaomoji` `gif` `center` |
| `keyboard` | `toggle` `open` `close` `letters` `fnkeys` `center` `bigger` `smaller` |
| `notifs` | `toggle` `open` `close` `clear` `toggleDnd` `expandAll` `settings` `count` |
| `lock` | `lock` `unlock` `isLocked` `status`: nada de esto evita la contraseña; PAM es la única forma de entrar |
| `snap` | `toggle` `open` `close` `text` `color` |
| `toast` | `show <icono> <etiqueta>` `warn <icono> <etiqueta>` |
| `screenshot` | `full` `text` |
| `media` | `toggle` `open` `close` `identify` `playPause` `next` `previous` |
| `workspaces` | `toggle` `open` `close` |
| `updates` | `status` `check` |
| `displays` | `list` `settings` `shell <dónde>` `bar <dónde>` `dock <dónde>`: *dónde* es el nombre de una salida, `left`/`middle`/`right`, `here`, `next`, `prev` o `auto` |
| `polkit` | `status` `demo <id-de-acción>` `fail` `grant` `close`: `demo` muestra el diálogo sin una sesión PAM detrás, para previsualizar un tema |
| `debug` | `toggle` `on` `off`: dibuja contornos de las regiones de entrada y desenfoque |

## Desinstalar

```sh
./uninstall.sh
```

Aparta `~/.config/quickshell` en lugar de borrarlo, así que tus ajustes sobreviven. Los
paquetes instalados por `install.sh` se dejan en paz. Imprime qué más dejó en su lugar
(los bloques de plantilla de matugen, `~/.config/hypr`, `starship.toml` y sus líneas de
inicio en tus archivos rc, los includes de color y opacidad de kitty), cada uno con una
copia de respaldo con marca de tiempo al lado, para que puedas deshacerlos a mano.

## Solución de problemas

**El visualizador de la ventana emergente de medios se queda plano y nunca se mueve.**
cava se está ejecutando sin `~/.config/cava/quickshell.conf`: sus valores por defecto
emiten salida ncurses en lugar de los fotogramas ascii en bruto que analiza la tira, así
que no hay nada que dibujar. Vuelve a ejecutar el instalador, o copia
`support/cava/quickshell.conf` ahí tú mismo. Antes de v1.0.0 esto se veía como una barra
enorme cubriendo la ventana emergente.

**Aparecen las notificaciones de otra app en lugar de las de Lucid.**
`org.freedesktop.Notifications` es un nombre D-Bus de un solo propietario. La barra de
Lucid lo sirve, pero cualquier otro demonio de notificaciones que simplemente esté
*instalado* (swaync, dunst, mako) es activado por D-Bus con la primera notificación y
luego conserva el nombre durante toda la sesión. No necesita estar en el autoinicio para
ganar. Comprueba quién lo tiene:

```sh
busctl --user status org.freedesktop.Notifications | grep PID
```

Si no es `quickshell`, enmascara el demonio y vuelve a iniciar sesión:

```sh
systemctl --user mask swaync.service   # o dunst.service, mako.service
pkill swaync
```

El instalador se ofrece a hacerlo por ti.


**Las apps GTK están en claro, o sus iconos son incorrectos.**
Bajo Hyprland no hay un demonio xsettings, así que GTK3/GTK4 leen
`~/.config/gtk-{3,4}.0/settings.ini` mientras que las apps GNOME y los portales leen
`gsettings`. El instalador escribe ambos. Si solo cambiaron algunas apps, comprueba que
concuerden:

```sh
gsettings get org.gnome.desktop.interface gtk-theme    # adw-gtk3-dark
gsettings get org.gnome.desktop.interface icon-theme   # FairyWren_Dark
grep -E 'theme-name' ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini
```

Los iconos viven en `~/.local/share/icons/FairyWren_Dark`. Si ese directorio falta, el
instalador no pudo llegar a GitLab: clónalo a mano desde
`https://gitlab.com/FreshDoctor/FairyWren-Icons`.

**No aparece nada al ejecutar `qs`.** Revisa `qs log` en busca de errores de QML, y
confirma que estás en Hyprland: Lucid necesita sus protocolos Wayland.

**Todo está gris / los colores se ven mal.** La caché de la paleta falta o está vacía.
Fija un fondo de pantalla en Ajustes → General, o copia una paleta incluida:
`cp ~/.config/lucid/themes/nord/quickshell.json ~/.cache/quickshell/matugen.json`

**El desenfoque escarcha mis ventanas en lugar del escritorio.** El desenfoque de
Hyprland muestrea lo que haya detrás de la capa. Añade a `hyprland.conf`:

```
layerrule = xray 1, quickshell
```

**Los iconos se ven borrosos.** Un factor de escala fraccionario de `monitor` pone los
iconos en píxeles fraccionarios. Usa una escala entera, o ajusta el tamaño de los iconos
en Ajustes.

**Las animaciones van entrecortadas en una tarjeta NVIDIA, incluso a 144 Hz o más.** El
plugin Wayland de Qt rechaza OpenGL con hilos en el controlador propietario de NVIDIA
(es su solución a [QTBUG-95817](https://bugreports.qt.io/browse/QTBUG-95817)), así que
Qt Quick recurre al bucle de renderizado básico, cuyo controlador de animación es un
temporizador fijo de ~16 ms sin conocimiento de vsync. Cada animación del shell queda
entonces fijada a ~60 fps sin importar qué tan rápido sea el monitor, por lo que Hyprland
se ve fluido mientras Lucid no.

Lucid arranca mediante `~/.config/lucid/launch-shell.sh`, que mueve esas máquinas al
backend Vulkan de Qt: Vulkan no tiene esa comprobación de proveedor, así que vuelven el
bucle con hilos y sus animaciones guiadas por vsync. Pregúntale qué decidió:

```sh
~/.config/lucid/launch-shell.sh --explain
```

Solo cambia cuando NVIDIA es la GPU en la que realmente renderiza el compositor, el
controlador es 555 o más nuevo y hay un controlador Vulkan de NVIDIA presente. Mesa ya
obtiene el bucle con hilos y se deja en paz. Anula la detección con
`LUCID_RHI_BACKEND=vulkan` o `LUCID_RHI_BACKEND=opengl`; un `QSG_RHI_BACKEND` existente en
tu entorno siempre gana.

**Un atajo con argumento no hace nada.** Añade `--` antes del objetivo:
`qs ipc call -- settings show bar`. Sin él `qs` interpreta el argumento como suyo y
rechaza la llamada. Las llamadas sin argumentos funcionan de cualquier forma.

## Contribuir

Issues y PRs son bienvenidos. Si reportas un error, la salida de `qs log` y tu versión de
Hyprland ayudan mucho.

## La marca

<img src="assets/logo-mark.svg" width="64" align="left" alt="La marca Lucida">

El logo es **Lucida**: el término astronómico para la estrella más brillante de una
constelación, que comparte su raíz latina (*lux*) con "Lucid". Un anillo orbital roto, una
estrella de cuatro puntas en el centro y un punto compañero fuera del hueco.

Su color oficial es el **coral `#FF7F50`**. En el propio shell el anillo y el punto
compañero siguen tu acento, así que la marca en el lanzador del dock se recolorea con la
paleta que estés usando, pero el coral es el color canónico de la marca, y lo que ves
arriba.

<br clear="left">

`assets/logo.svg` es la marca sobre su placa oscura; `assets/logo-mark.svg` es la marca
coral sola para fondos claros y oscuros por igual. Ambas se dibujan con la misma
geometría de 24×24 que [`LucidaMark.qml`](lucidprefs/LucidaMark.qml).

## Licencia

MIT: consulta [LICENSE](LICENSE).

Construido sobre [Quickshell](https://quickshell.org). Generación de colores por
[matugen](https://github.com/InioX/matugen). El diseño sigue
[Material 3 Expressive](https://m3.material.io).
