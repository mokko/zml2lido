class Jobs:
    def localLido(self):
        """
        localLido downloads images
        """
        mitSachbegriffZML = self.splitSachbegriff(
            Input=self.Input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(Input=mitSachbegriffZML)
        if self.validation:
            self.validate(Input=lido_fn)
        self.splitLido(input=lido_fn)  # individual records as files
        self.pix(Input=self.Input, output=self.output)  # transforms attachments
        self.lido2html(input=lido_fn)  # to make it easier to read lido

    def smbLido(self):
        """
        Make Lido that
        - image links: recherche.smb.
        - filter out records without sachbegriff
        - split
        - html
        """
        mitSachbegriffZML = self.splitSachbegriff(
            Input=self.Input
        )  # drop records without Sachbegriff
        lido_fn = self.zml2lido(Input=mitSachbegriffZML)
        linklido_fn = self.urlLido(Input=lido_fn)  # fix links and rm unpublished parts
        if self.validation:
            self.validate(Input=linklido_fn)
        self.splitLido(input=linklido_fn)  # individual records as files
        self.lido2html(input=linklido_fn)  # to make it easier to read lido

    def smb(self):
        """
        Make Lido
        - filter out lido records that are not published
        - image links: recherche.smb
        - validate if -v on command line
        - split
        """
        lido_fn = self.zml2lido(Input=self.Input)
        onlyPublished = self.onlyPublished(Input=lido_fn)
        linklido_fn = self.urlLido(
            Input=onlyPublished
        )  # fix links and rm unpublished parts
        if self.validation:
            self.validate(Input=linklido_fn)
        self.splitLido(Input=linklido_fn)  # individual records as files
        # self.lido2html(Input=linklido_fn)        # to make it easier to read lido

    def dd(self):
        """
        Make Lido for debug purposes
        - filter out lido records that are not published
        - image links: internal
        - validate if -v on command line
        - no split
        """
        lido_fn = self.zml2lido(Input=self.Input)
        self.validate(Input=lido_fn)
