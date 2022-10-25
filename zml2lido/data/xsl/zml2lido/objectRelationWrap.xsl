<xsl:stylesheet version="3.0"
	xmlns:func="http://func"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z func"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!--  
	objectRelationWrap(spec 1.0): Wrapper for infomation about related topics and works,
	collections, etc.
	
	Papa Bemba: For some reason, i cant find certain nodes.
	I find ObjObjectBRef nodes, but not ObjObjectARef. Why?
		z:moduleReference[@name = 'ObjObjectARef']
	In the end, i opt to show all related records, whether A or B

	LIDO1.1: SUBJECT
	A wrapper for information about the subject of the object/work in focus. The sub-elements identify, 
	describe, and/or interpret what is depicted in and by an object/work, or what it is about.

	14.2.2022 Frank möchte, dass relatedWork nur auf Objekte verweist, die auch smb-freigegeben sind
	Dafür muss ich in den jeweiligen DS des relatedWorks hineinschauen; dafür muss ich sicherstellen, dass
	ich den auch haben. Im vorliegenden Beispiel ist der jedoch nicht Teil der heruntergeladenen Objektgruppe.
	Das wird also eine größere Operation. Ich könnte z.B. in einem weiteren Schritt (ähnlich wie beim 
	LinkChecker) in RIA nachgucken, ob dieser DS freigegeben ist oder nicht und das entsprechend in LIDO
	korrigieren. TODO
	
	7.10.2022 Frank möchte jetzt Literaturangaben in relatedWorks haben. Dann muss ich zusehen, dass die 
	nicht wieder herausgefiltert werden an einem späteren Schritt.
	
	
	-->

	<xsl:template name="objectRelationWrap">
		<xsl:variable name="relatedWorks" select="z:composite[
			@name='ObjObjectCre'
		]/z:compositeItem/z:moduleReference
		or
		z:moduleReference[@name='ObjLiteratureRef']
		"/>
		
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
					<lido:relatedWorksWrap>
						<xsl:apply-templates select="z:composite[@name='ObjObjectCre']/z:compositeItem/z:moduleReference/z:moduleReferenceItem"/>
						<xsl:apply-templates select="z:moduleReference[@name='ObjLiteratureRef']/z:moduleReferenceItem"/>
					</lido:relatedWorksWrap>
				</xsl:if>
			</lido:objectRelationWrap>
		</xsl:if>
		<!-- xsl:message>
			<xsl:choose>
				<xsl:when test="z:repeatableGroup[@name='ObjIconographyGrp']">
					<xsl:message>ObjIconographyGrp</xsl:message>
				</xsl:when>
				<xsl:when test="z:repeatableGroup[@name='ObjKeyWordsGrp']">
					<xsl:message>ObjIconographyGrp</xsl:message>
				</xsl:when>
				<xsl:when test="$relatedWorks">
					<xsl:message>relatedWorks</xsl:message>
				</xsl:when>
			</xsl:choose>
		</xsl:message -->
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
					<xsl:value-of select="normalize-space(
						z:vocabularyReference[
							@name = 'TypeVoc'
						]/z:vocabularyReferenceItem/z:formattedValue
					)"/>
				</lido:extentSubject>
				<lido:subjectConcept>
					<xsl:if test="z:vocabularyReference[@instanceName = 'ObjKeyWordVgr']/z:vocabularyReferenceItem/@name">
						<lido:conceptID lido:type="URL" lido:source="iconclass">
							<xsl:value-of select="normalize-space(
								z:vocabularyReference[
									@instanceName = 'ObjKeyWordVgr'
								]/z:vocabularyReferenceItem/@name
							)"/>
						</lido:conceptID>
					</xsl:if>
					<xsl:apply-templates mode="index" select="z:dataField[@name = 'NotationTxt']/z:value"/>
				</lido:subjectConcept>
			</lido:subject>
		</lido:subjectSet>
    </xsl:template>

	<xsl:template mode="display" match="z:dataField[@name = 'NotationTxt']/z:value">
		<lido:displaySubject>
			<xsl:value-of select="normalize-space(.)"/>
		</lido:displaySubject>
	</xsl:template>

	<xsl:template mode="index" match="z:dataField[@name = 'NotationTxt']/z:value">
		<lido:term xml:lang="de">
			<xsl:value-of select="normalize-space(.)"/>
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
		<!-- subject is NOT repeatable, however subjectConcept is repeatable and has type --> 
		<xsl:variable name="aat" select="func:vocmap-replace-lax(
			'subjects', z:vocabularyReferenceItem/z:formattedValue, 'aatUri')"/>
		<xsl:variable name="euro" select="func:vocmap-replace-lax(
			'subjects', z:vocabularyReferenceItem/z:formattedValue, 'fashionUri')"/>
		<xsl:comment>
			<xsl:value-of select="z:vocabularyReferenceItem/@name"/>
		</xsl:comment>
		<lido:displaySubject xml:lang="de">
			<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue"/>
		</lido:displaySubject>
		<lido:subject>
			<lido:subjectConcept>
				<lido:conceptID lido:type="local" lido:source="SMB/RIA">
					<xsl:value-of select="z:vocabularyReferenceItem/@id"/>
				</lido:conceptID>
				<xsl:if test="$aat ne ''">
					<xsl:call-template name="subjectND">
						<xsl:with-param name="type">aat</xsl:with-param>
						<xsl:with-param name="uri" select="$aat"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="$euro ne ''">
					<xsl:call-template name="subjectND">
						<xsl:with-param name="type">europeanafashion</xsl:with-param>
						<xsl:with-param name="uri" select="$euro"/>
					</xsl:call-template>
				</xsl:if>
				<lido:term xml:lang="de">
					<xsl:value-of select="z:vocabularyReferenceItem/z:formattedValue"/>
				</lido:term>
			</lido:subjectConcept>
		</lido:subject>
	</xsl:template>

	<xsl:template name="subjectND"> <!-- ND: Norm data-->
		<xsl:param name="type"/>
		<xsl:param name="uri"/>
		<xsl:param name="term"/> <!-- can be empty-->

		<lido:conceptID lido:type="URI">
			<xsl:attribute name="lido:source">
					<xsl:value-of select="$type"/>
			</xsl:attribute>
			<xsl:value-of select="$uri"/>
		</lido:conceptID>
		<xsl:if test="$term ne ''">
			<lido:term xml:lang="de">
				<xsl:value-of select="$term"/>
			</lido:term>
		</xsl:if>
	</xsl:template>

	<xsl:template match="z:moduleReference[@name='ObjLiteratureRef']/z:moduleReferenceItem">
		<lido:relatedWorkSet>
            <lido:relatedWork>
                <lido:displayObject>
                    <xsl:value-of select="normalize-space(z:formattedValue)"/>
                </lido:displayObject>
				<lido:object>
					<lido:objectID lido:type="local">
						<xsl:attribute name="lido:source">
							<xsl:text>LIT.ID</xsl:text>
						</xsl:attribute>
						<xsl:value-of select="@moduleItemId"/>
					</lido:objectID>
				</lido:object>
			</lido:relatedWork>
			<!-- was: is related to, see #56-->
			<lido:relatedWorkRelType>
				<lido:conceptID lido:type="URI">http://terminology.lido-schema.org/lido00617</lido:conceptID>
				<lido:term xml:lang="en">is documented in</lido:term>
			</lido:relatedWorkRelType>
		</lido:relatedWorkSet>
	</xsl:template>

	<!-- ObjObjectCre -->
	<xsl:template match="z:composite[@name='ObjObjectCre']/z:compositeItem/z:moduleReference/z:moduleReferenceItem">
		<xsl:variable name="moduleItemId" select="@moduleItemId"/>
		<!-- We're assuming here that all relations are Objects -->
		<xsl:variable name="targetModule" select="../@targetModule"/>
		<xsl:variable name="url">
			<xsl:text>https://id.smb.museum/</xsl:text>
			<xsl:value-of select="lower-case($targetModule)"/> 
			<xsl:text>/</xsl:text>
			<xsl:value-of select="$moduleItemId"/> 
		</xsl:variable>
		<lido:relatedWorkSet>
            <lido:relatedWork>
                <lido:displayObject>
                    <xsl:value-of select="normalize-space(z:formattedValue)"/>
                </lido:displayObject>
				<lido:object>
					<lido:objectWebResource>
						<xsl:value-of select="$url"/>
					</lido:objectWebResource>
					<lido:objectID lido:type="local">
						<xsl:attribute name="lido:source">
							<xsl:choose>
								<xsl:when test="$targetModule eq 'Object'">
									<xsl:text>OBJ.ID</xsl:text>
								</xsl:when>
								<xsl:when test="$targetModule eq 'Person'">
									<xsl:text>KUE.ID</xsl:text>
								</xsl:when>
								<xsl:when test="$targetModule eq 'Multimedia'">
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
					    <xsl:value-of select="normalize-space(z:formattedValue)"/>
					</lido:objectNote>
				</lido:object>
            </lido:relatedWork>
            <lido:relatedWorkRelType>
                <lido:term xml:lang="de">
                    <xsl:value-of select="normalize-space(
						z:vocabularyReference[
							@name = 'TypeAVoc'
						]/z:vocabularyReferenceItem/z:formattedValue
					)"/>
                </lido:term>
            </lido:relatedWorkRelType>
        </lido:relatedWorkSet>
	</xsl:template>
 </xsl:stylesheet>