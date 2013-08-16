READ-ME:

------------------------------------------
SWFClasses
------------------------------------------
The package "SWFClasses" contains classes that are extended by MovieClips built in Flash Pro. Whenever they are changed, their respective .fla files must be re-compiled.

Each SWFClass has a note listing what .fla's use it.

IMPORTANT: THESE CLASSES SHOULD NOT HAVE 'SWFClasses' IN THEIR PACKAGE DECLARATION (FlashBuilder may put it in by default. if so, be sure to remove it).






-----------------------------------------------------------------
Flash Pro Conventions: 
All files built with Flash Pro must follow these conventions:
-----------------------------------------------------------------

--NAMING RULES---

The instance name of any symbol placed on stage must end in one of the three following suffixes:

	...MVC: A generic movieclip (Example: HealthBarMVC)
	...Btn: A button (Example: startBtn)
	...Txt: A text-field (Example: pointsTxt)

If a symbol is being exported, its symbol name must end in SWC. Otherwise, there are no rules governing symbol names. 


--TIMELINE RULES--

All frames of a timeline must contain the same symbols. For example, if fr.1 contains a button named 'startBtn', the entire timeline must contain that button.


--SWC RULES--

Save .swc files in the 'embedded_assets' package.

Do not use .swf files, because they require SWF loaders and can cause security issues (especially in older versions of flash player)

Each exported symbol should be its own .swc file. Do not export two symbols in the same .swc file. 

.swc files should have the same name as their content. For example, topBarSWC.swc should contain a movieclip named topBarSWC. 

.swc files should be named in camelCase, with a lowercase first word.

Classes extending a .swc file should be named the same as that file, but with a capital first letter.

Save classes extending .swc content in the 'embedded_asset_classes' package.

Every class extending a symbol should explitly explain the structure of that symbol.