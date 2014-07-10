#Gnome Google translator
Hotkey translator for Gnome uses Google and forms a vocabulary file to repeat unknown words before bedtime (later).

Vocabulary file is also useful if you suddenly lost internet.

The readme files on another languages you can see in the [docs/](https://github.com/newmen/gnome_google_translator/tree/master/docs) directory.

##Installing
Before, you need to install `xsel` application. For Fedora linux type `sudo yum -y install xsel` or apt-get instead yum if your linux is Ubuntu.

Clone this code `git clone https://github.com/newmen/gnome_google_translator` and go to the created folder `cd gnome_google_translator`. Next do not forget to make `bundle`, after that run the installer `ruby install.rb`

The installer will ask you about everything you like and tell you what to do next.

##Configuration
If after installation you decide that translator is wrong configured, and want to re-configure it - use the command `ruby configure.rb`.

##Details
Installer will create ~/bin/translate file, and if you want it will make hotkeys (Alt+F9 and Alt+Win+F9) for calling translator directly from X system. Thus if you need translate some text, you select it by mouse and press Alt+F9, after that translation popup as gnome notify. For translating some text from your own language to alternate language, that was specified during installation, you need to press Alt+Win+F9. You can change keyboard shortcuts for hot calling translator in the Gnome shortcuts settings anytime.

In addition, you can use it from the command line instead calling by selecting text and pressing hotkeys. It's enough to write, for example `translate Привет, Мир!`, and the translation appears in the same terminal.

The words that you transfer most often found above the rest in the vocabulary file. This is help you to remember the most "difficult" words before bedtime (it is enough to read (some time) the first few lines of the vocabulary file). Dictionary file is divided into two parts. The single words are presented in the first part and the collocations and phrases are presented in the second half. It is done to remember the fixed expressions, which are in each language. Too long sentences consisting of many words do not store in the vocabulary file.

Over time the words (or phrases) are removed from the vocabulary file, provided that you have learned them and did not resort to their translation. Definition of the words that you have learned, does every N days which you determined during the installation.

Before translation the text is subjected to additional processing. Newline characters are removed. Hyphenated words are glued together. Spaces are removed from the left and right of the text, and punctuation (just to the left and right).

##Acknowledgments
I thank the Habrahabr author (http://habrahabr.ru/blogs/linux/137215) for the great idea that inspired me to create this useless code.

Separately, I thank the following translators:

* Tran H. Que
* Renat Arifulov
* Nikolay Mamchenkov
