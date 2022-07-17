<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
    exclude-result-prefixes="z func"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<xsl:template name="recordWrap">
		<lido:recordWrap>
			<xsl:variable name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
			<lido:recordID lido:type="local" lido:source="SMB/Obj.ID">
				<xsl:value-of select="func:getISIL($verwaltendeInstitution)"/>
				<xsl:text>/</xsl:text>
				<xsl:value-of select="@id"/>
			</lido:recordID>
			<lido:recordType>
				<!-- 
					TODO: currently recordType is hardcoded. 
					How to decide if object is single object and what are the alternatives?
					For rst this is irrelevant
				-->
				<lido:conceptID lido:type="URI" lido:source="LIDO-Terminologie">http://terminology.lido-schema.org/lido00141</lido:conceptID>
				<lido:term xml:lang="de">Einzelobjekt</lido:term>
			</lido:recordType>
			<lido:recordSource lido:type="Institution">
				<xsl:call-template name="legalBody">
					<xsl:with-param name="verwaltendeInstitution" select="$verwaltendeInstitution"/>
				</xsl:call-template>
			</lido:recordSource>
			<lido:recordRights>
				<lido:rightsType>
                    <lido:conceptID lido:source="CC" lido:type="URI">https://creativecommons.org/share-your-work/public-domain/cc0/</lido:conceptID>
                    <lido:term xml:lang="en" lido:addedSearchTerm="no">No Rights Reserved</lido:term>
				</lido:rightsType>
				<xsl:call-template name="defaultRightsHolder"/>
			</lido:recordRights>
			<!-- 
				LIDO spec: Link of the metadata, e.g., to the object data sheet (not the same as link of the object).
				 We  want a link to smb-digital.de. Old eMuseum has this format 
				 http://smb-digital.de/eMuseumPlus?service=ExternalInterface&module=collection&objectId=255188&viewType=detailView 
			-->
			<lido:recordInfoSet>
                <xsl:if test="bearbStand">
                    <xsl:attribute name="lido:type">
                        <xsl:value-of select="bearbStand"/>
                    </xsl:attribute>
                </xsl:if>
				<lido:recordInfoLink lido:formatResource="html">				 
					<xsl:text>https://id.smb.museum/object/</xsl:text>
					<xsl:value-of select="@id"/>
				</lido:recordInfoLink>
			</lido:recordInfoSet>
		</lido:recordWrap>
	</xsl:template>
</xsl:stylesheet>