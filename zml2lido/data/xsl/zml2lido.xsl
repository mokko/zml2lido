<xsl:stylesheet 
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:func="http://func"
	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd"
	exclude-result-prefixes="z func">

	<xsl:import href="zml2lido/objectWorkTypeWrap.xsl" />
	<xsl:import href="zml2lido/classificationWrap.xsl" />
	<xsl:import href="zml2lido/objectIdentificationWrap.xsl" />
	<xsl:import href="zml2lido/eventWrap.xsl" />
	<xsl:import href="zml2lido/objectRelationWrap.xsl" />
	<xsl:import href="zml2lido/rightsWorkWrap.xsl" />
	<xsl:import href="zml2lido/recordWrap.xsl" />
	<xsl:import href="zml2lido/resourceWrap.xsl" />
	<xsl:import href="zml2lido/func.xsl" />

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<lido:lidoWrap 	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem" />
		</lido:lidoWrap>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem">
		<!--xsl:message>
			<xsl:text>D Object </xsl:text>
			<xsl:value-of select="@id"/>
		</xsl:message-->
		<xsl:choose>
			<xsl:when test=" normalize-space(z:moduleReference[@name='ObjOwnerRef']) ne ''">
				<xsl:call-template name="mitVerwInstitution"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="no">
					<xsl:text>WARN: record without verwaltendeInstitution is OMITTED! </xsl:text>
					<xsl:value-of select="@id"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="mitVerwInstitution">
		<xsl:variable name="verwaltendeInstitution" select="normalize-space(z:moduleReference[@name='ObjOwnerRef'])"/>
		<xsl:variable name="ISIL" select="func:getISIL($verwaltendeInstitution)"/>
	
		<lido:lido>
			<lido:lidoRecID>
				<xsl:choose>
					<xsl:when test="$ISIL ne ''">
						<xsl:attribute name="lido:source">ISIL (ISO 15511)/Obj.ID</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="lido:source">Obj.ID</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="lido:type">local</xsl:attribute>
					<xsl:if test="$ISIL ne ''">
						<xsl:value-of select="$ISIL" />
						<xsl:text>/</xsl:text>
					</xsl:if>
					<xsl:value-of select="@id" />
			</lido:lidoRecID>
			<xsl:comment>
				<xsl:text>objectPublishedID exists only if record has been published at SMB-Digital / recherche.smb. </xsl:text>
				<xsl:text>Publishing timestamp exists only for records that have been published since 2020-12-14.</xsl:text>
			</xsl:comment>
			<!--write objectPublishedID ONLY if -->
			<xsl:choose>
				<xsl:when test="z:repeatableGroup[@name='ObjPublicationGrp']/z:repeatableGroupItem[
					z:vocabularyReference[@name='PublicationVoc']/z:vocabularyReferenceItem/@name = 'Ja' 
					and z:vocabularyReference[@name='TypeVoc']/z:vocabularyReferenceItem/@name = 'Daten freigegeben für SMB-digital']">

					<lido:objectPublishedID lido:type="uri">
						<xsl:attribute name="lido:source">SMB identifier</xsl:attribute>
						<xsl:text>https://id.smb.museum/object/</xsl:text>
						<xsl:value-of select="@id" />
					</lido:objectPublishedID>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>
						<xsl:text>WARNING: Item not published at SMB-digital: </xsl:text>
						<xsl:value-of select="../@name" />
						<xsl:text> </xsl:text>
						<xsl:value-of select="@id" />
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="category" />

			<lido:descriptiveMetadata xml:lang="de">
				<xsl:call-template name="objectClassificationWrap" />
				<xsl:call-template name="objectIdentificationWrap" />
				<xsl:call-template name="eventWrap" />
				<!-- 
					20220219 I cant guarantee that the relatedObjects are online, so we're turning them off
					if you turn it off here you also turn off subjects
				-->
				<xsl:call-template name="objectRelationWrap" />
			</lido:descriptiveMetadata>

			<lido:administrativeMetadata xml:lang="de">
				<xsl:call-template name="rightsWorkWrap" />
				<xsl:call-template name="recordWrap" />
				<xsl:call-template name="resourceWrap" />
			</lido:administrativeMetadata>
		</lido:lido>
	</xsl:template>

	<xsl:template name="category">
		<!-- 
			introduce a new Objekttyp upstream 
			Objekttyp: Natürliches Objekt
		-->
		<lido:category>
			<xsl:choose>
				<xsl:when test="z:vocabularyReference[@name='ObjCategoryVoc']/z:formattedValue eq 'Natürliches Objekt'">
					<lido:conceptID lido:source="RIA:Objekttyp" lido:type="URI">http://vocab.getty.edu/aat/300404125</lido:conceptID>
					<lido:term xml:lang="en">Natural Object</lido:term>
					<lido:term xml:lang="de">Natürliches Objekt</lido:term>
				</xsl:when>
				<xsl:otherwise>
					<lido:conceptID lido:source="RIA:Objekttyp" lido:type="URI">http://www.cidoc-crm.org/cidoc-crm/E22</lido:conceptID>
					<lido:term xml:lang="de">Künstlicher Gegenstand</lido:term>
					<lido:term xml:lang="en">Human-Made Object</lido:term>
				</xsl:otherwise>
			</xsl:choose>
		</lido:category>
	</xsl:template>

	<xsl:template name="objectClassificationWrap">
		<lido:objectClassificationWrap>
			<xsl:call-template name="objectWorkTypeWrap" />
			<xsl:call-template name="classificationWrap" />
		</lido:objectClassificationWrap>
	</xsl:template>

	<!-- dryer LIDO -->
	<xsl:template name="conceptTerm">
		<xsl:comment>conceptTerm</xsl:comment>
		<lido:conceptID>
			<xsl:attribute name="lido:source">
				<xsl:value-of select="@instanceName" />
			</xsl:attribute>
			<xsl:attribute name="lido:type">
				<xsl:text>http://terminology.lido-schema.org/lido00100</xsl:text>
			</xsl:attribute>
			<xsl:value-of select="z:vocabularyReferenceItem/@id" />
		</lido:conceptID>
		<lido:term xml:lang="de">
			<xsl:value-of select="normalize-space(z:vocabularyReferenceItem/z:formattedValue)" />
		</lido:term>
	</xsl:template>
	
	<!-- remove garbage from unmapped fields -->
	<xsl:template match="z:dataField|z:moduleReference|z:systemField|z:VocabularyReference"/>

	<xsl:template name="legalBody">
		<xsl:param name="verwaltendeInstitution" required="yes"/> 
		<lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">
			<xsl:value-of select="func:getISIL($verwaltendeInstitution)"/>
		</lido:legalBodyID>
		<lido:legalBodyName>
			<lido:appellationValue>
				<xsl:value-of select="normalize-space($verwaltendeInstitution)" />
			</lido:appellationValue>
		</lido:legalBodyName>
		<lido:legalBodyWeblink>
			<xsl:value-of select="func:weblink($verwaltendeInstitution)"/>
		</lido:legalBodyWeblink>
	</xsl:template>

	<xsl:template name="sortorderAttribute">
		<xsl:variable name="sortno" select="normalize-space(z:dataField[@name='SortLnu']/z:value)"/>
		<xsl:if test="$sortno ne ''">
			<xsl:attribute name="lido:sortorder" select="$sortno"/>
		</xsl:if>
	</xsl:template>
	
	 <xsl:template name="defaultRightsHolder">
		<xsl:variable name="verwaltendeInstitution" select="z:moduleReference[@name = 'ObjOwnerRef']"/>
		<xsl:choose>
			<xsl:when test="normalize-space($verwaltendeInstitution) ne ''">
				<lido:rightsHolder>
					<xsl:call-template name="legalBody">
						<xsl:with-param name="verwaltendeInstitution" select="$verwaltendeInstitution"/>
					</xsl:call-template>
				</lido:rightsHolder>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>WARNING: No verwaltendeInstitution!</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>