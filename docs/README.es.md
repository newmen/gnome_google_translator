#Gnome Google traductor
Hotkey traductor para Gnome que usa Google y forma la ficha del vocabulario para repitir palabras traducidas, antes de acostarse.

La ficha del vocabulario es útil si no tiene accesso a Internet.

##Instalación
Hay que clonar eso: `git clone https://github.com/newmen/gnome_google_translator` y entrar en el directorio creado `cd gnome_google_translator`.
No se olvide hacer `bundle`, despues ejecuta el instalador `ruby install.rb`.

Instalador preguntara todo lo que necesita y dara los consejos que hacer.

##La configuracion
Si quiere hacer configuracion otra vez (para modificar algunos elementos) despues de la instalacion - hace `ruby configure.rb`.

##Los detalles
El instalador crea la ficha ~/bin/translate y si quiere hace hotkeys (Alt+F9 y Alt+Win+F9) para ejecutar el translador from X11.
Por ejemplo si es necesario de traducir algun texto tiene que вы выделяете его мышкой y pulsar el hotkey Alt+F9, luego que traducion aparece como gnome notificacion. Para traducir el texto del lengua materna a la lengua elegida durante la instalacion hay que pulsar Alt+Win+F9. Las combinaciones del hotkey puede cambiar en las preferenciones del Gnome.

Además de ejecutar el traductor por medio del hotkey puede hacer eso con la comanda en el terminal. Para eso hay que escribir en terminal, por ejemplo, `translate Hello Ruby` y la traducion representara en el terminal.

En la ficha del vocabulario las palabras que traduce mas frecuentemente estan en la parte de arriba de la ficha. Esto es asi para recordar rapidamente las palabras mas "dificiles" para usted. La ficha se divive en dos partes. La primer parte es para las palabras solitarias y la segunda parte para las combinaciones de palabras y para las oraciones. Las frases muy largas no conservan en la ficha del vocabulario.

Despues del numero of dias (este numero puede eligir durante la instalacion o cuando hace configuracion) las palabras son borradas de la ficha? si no traducia estas palabras otra vez durante el numero de los dias.

Antes de traduccion, hacemos unos cambios con el texto. Borramos los simbolos de nueva linea. Palabras con guión se pegan. Borramos los espacios y los simbolos de la punctuacion a la izquierda y a la derecha del texto.

##Las palabras de gracias
Quiero dar las gracias al autor del articulo en Habrahabr (http://habrahabr.ru/blogs/linux/137215), por excelente idea que inspiro me f crer este inutil script.