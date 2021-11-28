<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:import href="event-Herstellung.xsl"/>
    <xsl:import href="event-Erwerb.xsl" />
    <!-- xsl:import href="event-Sammeln.xsl" /-->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
        apparently some records with a Sammler dont have the Sammeln-event. 
        Why? Because i wrote eq Sammler instead of =. Let that be a lesson!
    -->
    <xsl:template name="eventWrap">
        <lido:eventWrap>
            <xsl:call-template name="Herstellung"/>			
            <xsl:if test="z:repeatableGroup[
				@name = 'ObjAcquisitionNotesGrp']/z:repeatableGroupItem[
				z:vocabularyReference/z:vocabularyReferenceItem/@name='Ausgabe']">
				<xsl:call-template name="Erwerb"/>
			</xsl:if>
            <!-- xsl:if test="z:personenKörperschaften[@funktion = 'Sammler']">
                <xsl:call-template name="Sammeln"/>
            </xsl:if -->
        </lido:eventWrap>
    </xsl:template>
</xsl:stylesheet>