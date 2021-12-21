<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!--  
	objectRelationWrap(spec 1.0): Wrapper for infomation about related topics and works,
	collections, etc.
	
	I dont understand why subjectWrap is an aspect of objectRelation, but who cares.

	Papa Bemba: For some reason, i cant find certain nodes.
	I find ObjObjectBRef nodes, but not ObjObjectARef. Why?
		z:moduleReference[@name = 'ObjObjectARef']
	In the end, i opt to show all related records, wether A or B
	-->

	<xsl:template name="objectRelationWrap">
		<xsl:variable name="relatedWorks" select="z:composite[
			@name='ObjObjectCre'
		]/z:compositeItem/z:moduleReference"/>
		<xsl:if test="z:repeatableGroup[@name='ObjIconographyGrp'] 
			or z:repeatableGroup[@name='ObjKeyWordsGrp']
			or $relatedWorks">
			<lido:objectRelationWrap>
				<xsl:if test="z:repeatableGroup[@name='ObjIconographyGrp'] or z:repeatableGroup[@name='ObjKeyWordsGrp']">
					<lido:subjectWrap>
						<xsl:apply-templates select="z:repeatableGroup[@name='ObjIconographyGrp']"/>
						<xsl:apply-templates select="z:repeatableGroup[@name='ObjKeyWordsGrp']"/>
					</lido:subjectWrap>
				</xsl:if>
				<!-- relatedWorksWrap -->
				<xsl:if test="$relatedWorks">
					<!--xsl:message>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</xsl:message-->
					<lido:relatedWorksWrap>
						<xsl:apply-templates select="z:composite[@name='ObjObjectCre']/z:compositeItem/z:moduleReference/z:moduleReferenceItem"/>
					</lido:relatedWorksWrap>
				</xsl:if>
			</lido:objectRelationWrap>
		</xsl:if>
    </xsl:template>

	<!--RIA:ICONCLASS-->

	<xsl:template match="z:repeatableGroup[@name='ObjKeyWordsGrp']">
		<xsl:apply-templates select="z:repeatableGroupItem">
			<xsl:sort select="z:dataField[@name='SortLnu']" data-type="number" order="ascending"/>
		</xsl:apply-templates>
    </xsl:template>
	
	<xsl:template match="z:repeatableGroup[@name='ObjKeyWordsGrp']/z:repeatableGroupItem">
		<lido:subjectSet>
			<xsl:call-template name="sortorderAttribute"/>
			<xsl:comment>ObjKeyWordsGrp</xsl:comment>
			<xsl:apply-templates mode="display" select="z:dataField[@name = 'NotationTxt']/z:value"/>
			<lido:subject>
				<lido:extentSubject>
					<xsl:value-of select="z:vocabularyReference[@name = 'TypeVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
				</lido:extentSubject>
				<lido:subjectConcept>
					<xsl:if test="z:vocabularyReference[@instanceName = 'ObjKeyWordVgr']/z:vocabularyReferenceItem/@name">
						<lido:conceptID lido:type="URL" lido:source="iconclass">
							<xsl:value-of select="z:vocabularyReference[@instanceName = 'ObjKeyWordVgr']/z:vocabularyReferenceItem/@name"/>
						</lido:conceptID>
					</xsl:if>
					<xsl:apply-templates mode="index" select="z:dataField[@name = 'NotationTxt']/z:value"/>
				</lido:subjectConcept>
			</lido:subject>
		</lido:subjectSet>
    </xsl:template>

	<xsl:template mode="display" match="z:dataField[@name = 'NotationTxt']/z:value">
		<lido:displaySubject>
			<xsl:value-of select="."/>
		</lido:displaySubject>
	</xsl:template>

	<xsl:template mode="index" match="z:dataField[@name = 'NotationTxt']/z:value">
		<lido:term xml:lang="de">
			<xsl:value-of select="."/>
		</lido:term>
	</xsl:template>


	<!-- 
		This is not good yet; this was made for Europeana:Fashion keywords but this source is not mentioned yet. 
		Let's not do that now. Instead, let's map other similar things and see how that changes the problem.
	-->
	<xsl:template match="z:repeatableGroup[@name='ObjIconographyGrp']">
			<xsl:apply-templates select="z:repeatableGroupItem[z:vocabularyReference[@name='KeywordProjectVoc']]">
				<xsl:sort select="z:dataField[@name='SortLnu']" data-type="number" order="ascending"/>
			</xsl:apply-templates>
	</xsl:template>

	<!-- todo: z:repeatableGroup[@name='ObjIconographyGrp']/z:repeatableGroupItem -->
	<xsl:template match="z:repeatableGroupItem[z:vocabularyReference[@name='KeywordProjectVoc']]">
		<lido:subjectSet>
			<xsl:call-template name="sortorderAttribute"/>
			<xsl:apply-templates select="z:vocabularyReference[@name = 'KeywordProjectVoc']"/>
		</lido:subjectSet>
	</xsl:template>

	<xsl:template match="z:vocabularyReference[@name = 'KeywordProjectVoc']">
		<lido:displaySubject xml:lang="de">
			<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue"/>
		</lido:displaySubject>
		<lido:subject>
			<lido:subjectConcept>
				<xsl:comment>
					<xsl:text>conceptID is an RIA internal id</xsl:text>
					<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
				</xsl:comment>
				<lido:conceptID lido:type="id">
					<xsl:value-of select="z:vocabularyReferenceItem/@id"/>
				</lido:conceptID>
				<lido:term xml:lang="de">
					<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue"/>
				</lido:term>
			</lido:subjectConcept>
		</lido:subject>
	</xsl:template>

	<!-- composite -->
	<xsl:template match="z:composite[@name='ObjObjectCre']/z:compositeItem/z:moduleReference/z:moduleReferenceItem">
		<xsl:variable name="moduleItemId" select="@moduleItemId"/>
		<xsl:variable name="url">
			<xsl:text>https://recherche.smb.museum/detail/</xsl:text>
			<xsl:value-of select="$moduleItemId"/> 
		</xsl:variable>
		<lido:relatedWorkSet>
            <lido:relatedWork>
                <lido:displayObject>
                    <xsl:value-of select="z:formattedValue"/>
                </lido:displayObject>
				<lido:object>
					<lido:objectWebResource>
						<xsl:value-of select="$url"/>
					</lido:objectWebResource>
					<lido:objectID lido:type="local">
						<xsl:attribute name="lido:source">
							<xsl:choose>
								<xsl:when test="..[@targetModule= 'Object']">
									<xsl:text>OBJ.ID</xsl:text>
								</xsl:when>
								<xsl:when test="..[@targetModule= 'Person']">
									<xsl:text>KUE.ID</xsl:text>
								</xsl:when>
								<xsl:when test="..[@targetModule= 'Multimedia']">
									<xsl:text>MM.ID</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:message terminate="yes">
										<xsl:text>ERROR: Unknown Object Type! </xsl:text>
										<xsl:value-of select="@targetModule"/> 
									</xsl:message>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:value-of select="$moduleItemId"/> 
					</lido:objectID>
					<!-- 
					not sure about objectNote
					
					SPEC: A descriptive identification of the object / work that will be
					meaningful to end-users, including some or all of the following
					information, as necessary for clarity and if known: title, object/work
					type, important actor, date and/or place information, potentially
					location of the object / work.
					-->
					<lido:objectNote>
					    <xsl:value-of select="z:formattedValue"/>
					</lido:objectNote>
				</lido:object>
            </lido:relatedWork>
            <lido:relatedWorkRelType>
                <lido:term xml:lang="de">
                    <xsl:value-of select="z:vocabularyReference[@name = 'TypeAVoc']/z:vocabularyReferenceItem/z:formattedValue"/>
                </lido:term>
            </lido:relatedWorkRelType>
        </lido:relatedWorkSet>
	</xsl:template>
 </xsl:stylesheet>