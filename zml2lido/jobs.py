class Jobs:
    def dd(self):
        """
        Make Lido for debug purposes
        (1) convert native xml to lido
        (2) always validate result

        No images are processed in this flavor and no internal links checked or
        rewritten.
        """
        lido_fn = self.zml2lido(Input=self.Input)
        self.validate(path=lido_fn)

    def localLido(self):
        """
        (1) only process object records with Sachbegriff
        (2) convert to lido
        (3) copy pix from mpApi (TO DO: needs update)

        We used to split big lido files into individual ones, but this step is
        not necessary at the moment.

        localLido used to convert lido to html for proof reading. But since
        FvH is doing the proofing I haven't used this function in a long time.

        Keeps internal urls.

        Option
        - for validation use command line option -v

        Used In
        - this flavor is currently in use for the rst project.
        """

        mitSachbegriffZML = self.splitSachbegriff(
            Input=self.Input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(Input=mitSachbegriffZML)
        if self.validation:
            self.validate(path=lido_fn)
        # self.splitLido(input=lido_fn)  # individual records as files
        self.pix(Input=self.Input, output=self.output)  # transforms attachments
        # self.lido2html(input=lido_fn)  # to make it easier to read lido

    def smbLido(self):
        """
        (1) drop records without Sachbegriff in native xml
        (2) rewrite and check internal links with recherche.smb links
        (3) split into individual lido records

        Optional
        - validate with -v on command line

        Used In
        - currently not used on a regular basis

        Used to
        - make html representation as step 5
        """
        mitSachbegriffZML = self.splitSachbegriff(
            Input=self.Input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(Input=mitSachbegriffZML)
        # fix internal links and rm unpublished parts
        rewrite_fn = self.urlLido(Input=lido_fn)
        if self.validation:
            self.validate(path=rewrite_fn)
        self.splitLido(input=rewrite_fn)  # individual records as files
        # self.lido2html(input=linklido_fn)  # to make it easier to read lido

    def smb(self):
        self.mitLit()

    def mitLit(self):
        """
        This job used to be called 'smb'. It has all fields that have been mapped, incl. rudimentary
        literature reference inside of lido:relatedWorks. The alternative is to use ohneLit.

        (1) convert from native xml to lido
        (2) Python transformation which corrects relatedWorks
        (3) validate lido (optional)
        (3) split lido into single files

        NEW:
        - no more link rewriting and checking for linkResources
        - include ISIL to relatedWorks
        - relatedWorks are being checked if they are online; if not they are deleted from lido.

        Optional
        - validate using command line switch -v

        Used to
        - rewrite and check internal links using recherche.smb urls
        - create html versions of lido

        """
        # (1) convert input to lido using
        lido_fn = self.zml2lido(Input=self.Input)
        # (2) call LinkChecker: fix links and rm unpublished parts
        # onlyPublished = self.onlyPublished(Input=lido_fn)
        rewrite_fn = self.urlLido(Input=lido_fn)
        # (3) validate
        if self.validation:
            self.validate(path=rewrite_fn)
        # (4) split big lido file into small ones
        self.splitLido(Input=rewrite_fn)

    def ohneLit(self):
        lido_fn = self.zml2lido(Input=self.Input, xslt="ohneLit")
        rewrite_fn = self.urlLido(Input=lido_fn)
        if self.validation:
            self.validate(path=rewrite_fn)
        self.splitLido(Input=rewrite_fn)
