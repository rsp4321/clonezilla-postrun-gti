# clonezilla-postrun-gti
Postrun script system for Clonezilla's massive deployment mode

## Warning!
This code was developed initially with portuguese terms because it was intended for local use on a brazilian school. After succeded use in that school, I decided to share this because I didn't find similar solution on the web and I believe that this project would help some massive deployment of Active Directory based OS images. **I'm sorry for the mixed content with english terms and I shall translate them in future. If you had problems with these terms, you can issue them for translation. :^S**


## About
This project was intended to make Clonezilla run postrun scripts on clients in a massive deployment scenario. Clonezilla's default postrun mode only runs when used in a single, local deployment of a machine.

This permits extended funcionality on standalone massive deployment scenarios like automated Active Directory join included in the examples folder.


## How it works?
The prerun script is injected on the ISO of Clonezilla. In massive deployment mode, they will copy custom postrun scripts from the server to the clients and run them.


## How to use?
* Inject the prerun script in the prerun folder in a Clonezilla image. [This guide may help injecting them.](https://drbl.org/fine-print.php?path=./faq/2_System/81_add_prog_in_filesystem-squashfs.faq#81_add_prog_in_filesystem-squashfs.faq) You can download an modified image [here](https://github.com/rsp4321/clonezilla-postrun-gti/releases).
* Boot the modified ISO and open the shell
* Remove the _*.sh_ extension from  scripts' filename
* Zip the postrun scripts in file named *"gti-postrun.zip"*
* Copy the zip to the TFTP server folder */tftboot/nbi_img*
* Open clonezilla's *expert mode* and enable *PRERUN* and *POSTRUN* script execution
