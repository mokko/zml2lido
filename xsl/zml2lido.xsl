<xsl:stylesheet 
	version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:lido="http://www.lido-schema.org"
	xmlns:z="http://www.zetcom.com/ria/ws/module"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
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
				<xsl:text>objectPublishedID exists only if record has been published at SMB-Digital / recherche.smb. </xsl:text>
				<xsl:text>Publishing timestamp exists only for records that have been published since 2020-12-14.</xsl:text>
			</xsl:comment>
			<!--write objectPublishedID ONLY if -->
			<xsl:choose>
				<xsl:when test="z:repeatableGroup[@name='ObjPublicationGrp']/z:repeatableGroupItem[
					z:vocabularyReference[@name='PublicationVoc']/z:vocabularyReferenceItem/@name = 'Ja' 
					and z:vocabularyReference[@name='TypeVoc']/z:vocabularyReferenceItem/@name = 'Daten freigegeben für SMB-digital']">

					<!--sometimes identical date is repeated; not sure why, so just taking first -->
					<xsl:variable name="pubdate" select="z:repeatableGroup[
						@name='ObjPublicationGrp']/z:repeatableGroupItem[1]/z:dataField[@name='ModifiedDateDat']/z:value"/>
					<lido:objectPublishedID lido:source="ISIL (ISO 15511)/Obj.ID/publishing-timeStamp" lido:type="local">
						<xsl:value-of select="func:getISIL($verwaltendeInstitution)" />
						<xsl:text>/</xsl:text>
						<xsl:value-of select="@id" />
						<xsl:if test="$pubdate">
							<xsl:text>/</xsl:text>
							<xsl:value-of select="$pubdate" />
						</xsl:if>
						<!-- old date: z:systemField[@name='__lastModified']/z:value--> 
					</lido:objectPublishedID>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>
						<xsl:text>not published at SMB-digital: </xsl:text>
						<xsl:value-of select="@id" />
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
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
				<xsl:text>http://terminology.lido-schema.org/lido00100</xsl:text>
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
		<!-- used to be eq; unclear why now =. There should be only one match. With = i get schema error. -->
		<xsl:variable name="return" select="$dict/vocmap/voc[@name eq $src-voc]/concept[source eq $src-term]/target[@name eq $target]/text()"/>
		<!-- die if replacement returns empty, except if source is already empty -->
		<xsl:if test="normalize-space($return) = '' and normalize-space($src-term) != ''">
			<xsl:message terminate="yes">
				<xsl:text>ERROR: vocmap-replace returns EMPTY ON </xsl:text>
				<xsl:value-of select="$src-term"/> 
				<xsl:text> FROM </xsl:text>
				<xsl:value-of select="$src-voc"/> 
			</xsl:message>
		</xsl:if> 
		<xsl:value-of select="$return"/>
	</xsl:function>

	<!-- Man kann die ISIL in MuseumPlus unter der PK-DS der verwaltenden Institution im Register Normdaten nachgucken-->
	<xsl:function name="func:getISIL">
		<xsl:param name="verwaltendeInstitution"/>
		<xsl:value-of select="func:vocmap-replace('verwaltendeInstitution', $verwaltendeInstitution, 'ISIL')" />
	</xsl:function>

	<xsl:function name="func:weblink">
		<xsl:param name="verwaltendeInstitution"/>
		<xsl:value-of select="func:vocmap-replace('verwaltendeInstitution', $verwaltendeInstitution, 'homepage')" />
	</xsl:function>

	<xsl:function name="func:reformatDate">
		<!-- 
			takes input in format [{\d|\d\d}\.[{\d|\d\d}\.]]\d{1-4} 
			and returns YYYY[-MM[-DD]] according to LIDO spec 1.0.

			TODO: now limitation is with negative years which fits the ISO 8601 quite well
			
			Wikipedia about ISO 8601's treatment of years: "ISO 8601 prescribes, as a minimum, 
			a four-digit year [YYYY] to avoid the year 2000 problem. It therefore represents years 
			from 0000 to 9999, year 0000 being equal to 1 BC and all others AD. However, years 
			before 1583 are not automatically allowed by the standard. Instead 'values in the 
			range [0000] through [1582] shall only be used by mutual agreement of the partners in 
			information interchange.'"

			LIDO Spec also mentions  time, but haven't encountered that yet.
			
			Accepts only a single value, no sequence - which, emphatically, is a feature not a bug.
		-->
		<xsl:param name="date"/>
		<!--xsl:message>
			<xsl:value-of select="$date"/>
			<xsl:text> [</xsl:text>
			<xsl:value-of select="count($date)"/>
			<xsl:text>]</xsl:text>
		</xsl:message-->

		<xsl:variable name="date2" select="normalize-space($date)"/>
		<!-- what about years before 0? -->
		<xsl:variable name="y" select="analyze-string($date2, '(\d|\d\d|\d{3}|\d{4})$')//fn:match/fn:group[@nr = 1]"/>
		<xsl:variable name="m" select="analyze-string($date2, '(\d|\d\d)\.\d+$')//fn:match/fn:group[@nr = 1]"/>
		<xsl:variable name="d" select="analyze-string($date2, '^(\d|\d\d)\.\d+\.\d+')//fn:match/fn:group[@nr = 1]"/>

		<xsl:variable name="yyyy">
			<xsl:if test="$y ne ''">
				<xsl:value-of select="format-number(number($y),'0000')"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="mm">
			<xsl:if test="$m ne ''">
				<xsl:value-of select="format-number(number($m),'00')"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="dd">
			<xsl:if test="$d ne ''">
				<xsl:value-of select="format-number(number($d),'00')"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="new">
			<xsl:value-of select="$yyyy"/>
			<xsl:if test="$mm ne ''">
				<xsl:text>-</xsl:text>
				<xsl:value-of select="$mm"/>
			</xsl:if>
			<xsl:if test="$dd ne ''">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="$dd"/>
			</xsl:if>
		</xsl:variable>
		<xsl:message>
			<xsl:text> reformatDate: </xsl:text>
			<xsl:value-of select="$date" />
			<xsl:text> :: </xsl:text>
			<xsl:value-of select="$new" />
		</xsl:message>
		<xsl:value-of select="$new" />
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

	<xsl:template name="sortorderAttribute">
		<xsl:if test="z:dataField[@name='SortLnu'] ne ''">
			<xsl:attribute name="lido:sortorder" select="z:dataField[@name='SortLnu']"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>