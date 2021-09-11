<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
	<xsl:import href="titleWrap.xsl" />
	<xsl:import href="repositoryWrap.xsl" />
	<xsl:import href="objectDescriptionWrap.xsl" />
	<xsl:import href="objectMeasurementsWrap.xsl" />

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="objectIdentificationWrap">
        <lido:objectIdentificationWrap>
            <xsl:call-template name="titleWrap"/>
            <xsl:call-template name="inscriptionsWrap"/>
            <xsl:call-template name="repositoryWrap"/>
            <!-- lido:displayStateEditionWrap: A wrapper for the state and edition of the object / work (optional) -->
            <xsl:call-template name="objectDescriptionWrap"/>
            <xsl:call-template name="objectMeasurementsWrap"/>
        </lido:objectIdentificationWrap>
    </xsl:template>

	<!-- todo -->
    <xsl:template name="inscriptionsWrap"/>
    
</xsl:stylesheet>