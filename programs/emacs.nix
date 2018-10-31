/*
$ nix-build emacs.nix

To run the newly compiled executable:

$ ./result/bin/emacs
*/
{ pkgs ? import <nixpkgs> {} }:

let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages; 
  trivialBuild = pkgs.callPackage <nixpkgs/pkgs/build-support/emacs/trivial.nix> {
	emacs = myEmacs;
  };
  myModConf = pkgs.emacsPackagesNg.trivialBuild {
	pname = "default-config";
	version = "2018-10-31";
	src = pkgs.writeText "default.el" ''
		(load-theme 'tango-dark)
		(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
		(autoload 'haskell-mode "haskell-mode")
		(add-hook 'haskell-mode-hook 'haskell-indentation-mode)
		(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
		(add-to-list 'completion-ignored-extensions ".hi")
		(custom-set-variables
			'(haskell-stylish-on-save t))

		
	'';
  };
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [ 
    haskell-mode
    hindent
    paredit
    magit          # ; Integrate git <C-x g>
#    zerodark-theme # ; Nicolas' theme
  ]) ++ (with epkgs.melpaPackages; [ 
    #zoom-frm       # ; increase/decrease font size for all buffers %lt;C-x C-+>
  ]) ++ (with epkgs.elpaPackages; [ 
    undo-tree
    auctex         # ; LaTeX mode
    beacon         # ; highlight my cursor when scrolling
    nameless       # ; hide current package name everywhere in elisp code
    company
  ]) ++ [
    pkgs.notmuch   # From main packages set 
    myModConf
  ])
