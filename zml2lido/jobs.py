class Jobs:
    def dd(self):
        """
        Make Lido for debug purposes
        (1) convert native xml to lido
        (2) validate always

        No images are processed in this flavor and no internal links checked or rewritten.
        """
        lido_fn = self.zml2lido(Input=self.Input)
        self.validate(Input=lido_fn)

    def localLido(self):
        """
        (1) only process object records with Sachbegriff
        (2) convert to lido
        (3) split lido into single files
        (4) copy pix from mpApi (needs update)

        It used to convert lido to html representation for proof reading
        But since FvH is doing the proofing I haven't used this function
        in a long time
        (5) used to: prepare html version (not used in a long time)

        Option:
        - for validation use command line option -v

        This flavor is currently used for the rst project.
        """

        mitSachbegriffZML = self.splitSachbegriff(
            Input=self.Input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(Input=mitSachbegriffZML)
        if self.validation:
            self.validate(Input=lido_fn)
        self.splitLido(input=lido_fn)  # individual records as files
        self.pix(Input=self.Input, output=self.output)  # transforms attachments
        # self.lido2html(input=lido_fn)  # to make it easier to read lido

    def smbLido(self):
        """
        (1) drop records without Sachbegriff in native xml
        (2) rewrite and check internal links with recherche.smb links
        (3) split into individual lido records
        (4) used to: make html representation

        Optional
        - validate with -v on command line
        """
        mitSachbegriffZML = self.splitSachbegriff(
            Input=self.Input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(Input=mitSachbegriffZML)
        linklido_fn = self.urlLido(Input=lido_fn)  # fix links and rm unpublished parts
        if self.validation:
            self.validate(Input=linklido_fn)
        self.splitLido(input=linklido_fn)  # individual records as files
        # self.lido2html(input=linklido_fn)  # to make it easier to read lido

    def smb(self):
        """
        (1) convert from native xml to lido
        (2) filter out records that are not published on recherche.smb
        (3) rewrite and check internal links using recherche.smb urls
        (4) split lido into single files
        optionally: validate using command line -v

        De we also rewrite internal links to recherche.smb links?

        This seems to be the default flavor for FvH.
        """
        lido_fn = self.zml2lido(Input=self.Input)
        onlyPublished = self.onlyPublished(Input=lido_fn)
        linklido_fn = self.urlLido(
            Input=onlyPublished
        )  # fix links and rm unpublished parts
        if self.validation:
            self.validate(Input=linklido_fn)
        self.splitLido(Input=linklido_fn)
        # self.lido2html(Input=linklido_fn)
