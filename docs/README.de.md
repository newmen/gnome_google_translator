#Gnome Google Übersetzer
Ein Hotkey Übersetzer benutzt Google und erstellt einen Wörterbuch-Datei für die Wiederholung der schon übersetzten Wörter, bevor Sie schlafen gehen.

Die Wörterbuch-Datei kann auch nützlich sein, wenn Ihre Internet-Anschlüss unerwartet abgebrochen wird.

##Installing
Klonieren Sie den Code `git clone https://github.com/newmen/gnome_google_translator` und gehen zum erstellten Ordner. Vergessen Sie nicht dann `bundle`. Weiter istallieren das Programm aus Installer-Datei `ruby install.rb`.

Alle Einstellungen können Sie durch Installation machen, außerdem bekommen Sie den Hinweis, was Sie weiter machen sollten.

##Configuration
Unpasst die früher gemachte Einstellungen Ihnen, so können Sie die neue durch `ruby configure.rb`-Komande machen.

##Verwendung
Bei der Intallation wird den ~/bin/translate-Datei erstellt und hotkeys (Alt+F9 und Alt+Win+F9), wenn Sie wünschen, damit der Übersetzer gerade aus X-System aufgeruft werden kann. Also, wenn Sie einen Text übersetzen brauchen, so markieren Sie den mit der Maus und drücken Sie Alt+F9. Die Übersetzung bekommen Sie als gnome notify. Für die Übersetzung des Textes aus Ihrer Muttersprache auf eine andere Sprache, die bei der Installation ausgewählt wurde, drücken Sie Alt+Win+F9. Sie können immer ändern Hotkey für den Aufruf des Übersetzers in der Hotkey-Einstellungen in Gnome.

Außer Aufruf des Übersetzers durch die Markierung des Textes und Hotkey-Eintasten können Sie das gerade aus der Befehlszeile machen. Es ist genug, `translate Hello Ruby` zu schreiben, und Übersetzung erhalten Sie in diesem Terminal.

Wörter in Wörterbuch sind so geordnet, dass die oftmals übersetzte Wörter höher als andere sind. Es ist damit getan, dass Sie bevor schlaf wirklich schwere für Sie Wörter behalten konnten (Sie sollten einfach mehrmals die oben angeordnete Zeile im Wörterbuch lesen). Die Wörterbuch-Datei ist auf die zwei  Teile geteilt. Im ersten Teil werden Wörter gezeigt, und im anderen Teil Wortverbindungen und Sätze. Es ist damit gemacht, dass Sie Ausdrücke behalten könnten. Zu länge Ausdrücke mit viele Wörter werden in der Wörterbuch-Datei nicht gespeichert.

Wörter und Ausdrücke werden später aus der Wörterbuch-Datei gelöst, Wenn Sie sie behalten und nicht Wieder neu übersetzt haben. Prüfung der behaltenen Wörter lauft eins Mal pro bei der Installation eingestellte N Tage.

Bevor Übersetzung wird der Text zusätzlich vorbereitet. Tabulation wird gelöst. Übersetzung der Wörter wird gelöst. Zeichensetzung vor und nach dem Text wird gelöst.
