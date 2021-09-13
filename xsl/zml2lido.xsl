<xsl:stylesheet 
	version="2.0"
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

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />

	<xsl:template match="/">
		<lido:lidoWrap 	xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">
			<xsl:apply-templates select="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem" />
		</lido:lidoWrap>
	</xsl:template>

	<xsl:template match="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem">
		<xsl:variable name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
		<lido:lido>
			<lido:lidoRecID>
				<xsl:attribute name="lido:source">ISIL (ISO 15511)/Obj.ID</xsl:attribute>
				<xsl:attribute name="lido:type">local</xsl:attribute>
					<xsl:value-of select="func:getISIL($verwaltendeInstitution)" />
					<xsl:text>/</xsl:text>
					<xsl:value-of select="@id" />
			</lido:lidoRecID>
			<xsl:comment>
				<xsl:text> Should be publishing date, but record is not published yet, so please overwrite upstream. </xsl:text>
				<xsl:text> Included for illustration only, using date lastModified</xsl:text>
			</xsl:comment>
			<lido:objectPublishedID lido:source="ISIL (ISO 15511)/Obj.ID/publishing-timeStamp" lido:type="local">
				<xsl:value-of select="func:getISIL($verwaltendeInstitution)" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="@id" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="z:systemField[@name='__lastModified']/z:value" />
			</lido:objectPublishedID>
			<xsl:call-template name="category" />

			<lido:descriptiveMetadata xml:lang="de">
				<xsl:call-template name="objectClassificationWrap" />
				<xsl:call-template name="objectIdentificationWrap" />
				<xsl:call-template name="eventWrap" />
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
		<!-- Not sure how to map this, perhaps introduce a new Objekttyp upstream -->
		<lido:category>
			<lido:conceptID lido:type="URI">http://www.cidoc-crm.org/crm-concepts/E22</lido:conceptID>
			<lido:term xml:lang="en">Human-Made Object</lido:term>
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
				<xsl:value-of select="internalID" />
			</xsl:attribute>
			<xsl:value-of select="z:vocabularyReferenceItem/@id" />
		</lido:conceptID>
		<lido:term xml:lang="de">
			<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue" />
		</lido:term>
	</xsl:template>
	
	<!-- remove garbage from unmapped fields -->
	<xsl:template match="z:dataField|z:moduleReference|z:systemField|z:VocabularyReference"/>

	<xsl:function name="func:vocmap-replace">
		<xsl:param name="src-voc"/>
		<xsl:param name="src-term"/>
		<xsl:param name="target"/>
		<xsl:variable name="dict" select="document('file:vocmap.xml')"/>
		<xsl:variable name="return" select="$dict/vocmap/voc[@name eq $src-voc]/concept[source eq $src-term]/target[@name = $target]"/>

		<!-- die if replacement returns empty, except if source is already empty -->
		<xsl:if test="not($return) and $src-term">
			<xsl:message terminate="yes">
				ERROR: vocmap-replace returns EMPTY ON <xsl:value-of select="$src-term"/> FROM <xsl:value-of select="$src-voc"/> 
			</xsl:message>
		</xsl:if>
		<!--xsl:message terminate="no">
			VOCMAP-REPLACE <xsl:value-of select="$src-term"/>
			<xsl:text> </xsl:text>
		</xsl:message-->
		<xsl:value-of select="$return"/>
	</xsl:function>

	<!-- Man kann die ISIL in MuseumPlus unter der PK-DS der verwaltenden Institution im Register Normdaten nachgucken-->
	<xsl:function name="func:getISIL">
		<xsl:param name="verwaltendeInstitution"/>
		<xsl:choose>
			<xsl:when test="$verwaltendeInstitution eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
				<xsl:text>DE-MUS-019014</xsl:text>
			</xsl:when>
			<xsl:when test="$verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
				<xsl:text>DE-MUS-019118</xsl:text>
			</xsl:when>
			<xsl:when test="$verwaltendeInstitution eq 'Museum für Islamische Kunst, Staatliche Museen zu Berlin'">
				<xsl:text>DE-MUS-814517</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>FEHLER: UNBEKANNTE INSTITUTION FÜR ISIL (FUNKTION): </xsl:text>
					<xsl:value-of select="$verwaltendeInstitution"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="func:weblink">
		<xsl:param name="verwaltendeInstitution"/>
		<xsl:choose>
			<xsl:when test="$verwaltendeInstitution eq 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
				<xsl:text>https://www.smb.museum/aku</xsl:text>
			</xsl:when>
			<xsl:when test="$verwaltendeInstitution eq 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
				<xsl:text>https://www.smb.museum/em</xsl:text>
			</xsl:when>
			<xsl:when test="$verwaltendeInstitution eq 'Museum für Islamische Kunst, Staatliche Museen zu Berlin'">
				<xsl:text>https://www.smb.museum/isl</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>FEHLER: UNBEKANNTER WEBLINK</xsl:text>
					<xsl:value-of select="$verwaltendeInstitution"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="legalBody">
		<xsl:param name="verwaltendeInstitution" required="yes"/> 
		<lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">
			<xsl:value-of select="func:getISIL($verwaltendeInstitution)"/>
		</lido:legalBodyID>
		<lido:legalBodyName>
			<lido:appellationValue>
				<xsl:value-of select="$verwaltendeInstitution" />
			</lido:appellationValue>
		</lido:legalBodyName>
		<lido:legalBodyWeblink>
			<xsl:value-of select="func:weblink($verwaltendeInstitution)"/>
		</lido:legalBodyWeblink>
	</xsl:template>
</xsl:stylesheet>