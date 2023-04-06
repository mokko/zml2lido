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
		<xsl:variable name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
		<xsl:variable name="ISIL" select="func:getISIL($verwaltendeInstitution)"/>
		<lido:recordWrap>
			<lido:recordID lido:type="local">
				<xsl:attribute name="lido:source">
					<xsl:if test="$verwaltendeInstitution ne ''">
						<xsl:text>ISIL/</xsl:text>
					</xsl:if>
					<xsl:text>Obj.ID</xsl:text>
				</xsl:attribute>
				<xsl:if test="$verwaltendeInstitution ne ''">
					<xsl:value-of select="$ISIL"/>
					<xsl:text>/</xsl:text>
				</xsl:if>
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
			<xsl:if test="$verwaltendeInstitution ne ''">
				<!-- recordSource is required!!! -->
				<xsl:call-template name="recSource"/>
				<xsl:call-template name="recRights"/>
				<xsl:call-template name="recInfo"/>

			</xsl:if>
			<!-- 
				LIDO spec: Link of the metadata, e.g., to the object data sheet (not the same as link of the object).
				 We  want a link to smb-digital.de. Old eMuseum has this format 
				 http://smb-digital.de/eMuseumPlus?service=ExternalInterface&module=collection&objectId=255188&viewType=detailView 
			-->
		</lido:recordWrap>
	</xsl:template>
	
	<xsl:template name="recSource">
		<lido:recordSource lido:type="Institution">
			<xsl:call-template name="legalBody">
				<xsl:with-param name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
			</xsl:call-template>
		</lido:recordSource>	
	</xsl:template>
	
	<!-- 
	20230406 FvH wants records in more restrictive license again (CC-BY-SA), instead CC0
	-->

	<xsl:template name="recRights">
		<lido:recordRights>
			<lido:rightsType>
				<lido:conceptID lido:source="CC" lido:type="URI">https://creativecommons.org/licenses/by-sa/4.0/</lido:conceptID>
				<lido:term xml:lang="en" lido:addedSearchTerm="no">CC BY-SA 4.0</lido:term>
			</lido:rightsType>
			<xsl:call-template name="defaultRightsHolder"/>
		</lido:recordRights>
	</xsl:template>

	<xsl:template name="recInfo">	
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
	</xsl:template>
</xsl:stylesheet>