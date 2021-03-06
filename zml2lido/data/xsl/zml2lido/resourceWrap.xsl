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

	<xsl:template name="resourceWrap">
        <xsl:variable name="objId" select="z:systemField[@name='__id']" />
		<xsl:variable name="verwaltendeInstitution" select="z:moduleReference[@name='ObjOwnerRef']"/>
        <xsl:variable name="verknüpfteMM" select="/z:application/z:modules/z:module[@name = 'Multimedia']
			/z:moduleItem[
				 z:composite[@name = 'MulReferencesCre']
					/z:compositeItem/z:moduleReference[@name = 'MulObjectRef']
					/z:moduleReferenceItem[@moduleItemId = $objId]
				and	z:repeatableGroup[@name = 'MulApprovalGrp']
					/z:repeatableGroupItem/z:vocabularyReference[@instanceName='MulApprovalTypeVgr']
					/z:vocabularyReferenceItem[@name ='SMB-digital']
				and z:repeatableGroup[@name = 'MulApprovalGrp']
					/z:repeatableGroupItem/z:vocabularyReference[@instanceName='MulApprovalVgr']
					/z:vocabularyReferenceItem[@name ='Ja']
		]"/>

		<!--xsl:message>
			<xsl:value-of select="$objId"/>
			<xsl:text>:::</xsl:text>
			<xsl:for-each select="$verknüpfteMM">
				<xsl:value-of select="z:systemField[@name='__id']"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="z:systemField[@name='__id']"/>
			</xsl:for-each>
		</xsl:message-->
		<xsl:if test="$verknüpfteMM">
			<lido:resourceWrap>
				<xsl:apply-templates mode="resourceWrap" select="$verknüpfteMM">
					<xsl:with-param name="objId" select="$objId"/>
					<xsl:with-param name="verwaltendeInstitution" select="$verwaltendeInstitution"/>
				</xsl:apply-templates>
			</lido:resourceWrap>
		</xsl:if>
    </xsl:template>

    <xsl:template mode="resourceWrap" match="/z:application/z:modules/z:module[@name = 'Multimedia']/z:moduleItem">
		<xsl:param name="objId"/>
		<xsl:param name="verwaltendeInstitution"/>
		
		<!-- 
			<xsl:variable name="bereich" select="z:systemField[@name = '__orgUnit']"/>
			<xsl:variable name="verwaltendeInstitution" 
				select="func:vocmap-replace('Bereich', $bereich, 'verwaltendeInstitution')"/>
			OLD VERSION xsl:variable name="objId" 
			select="z:composite[
				@name eq 'MulReferencesCre'
			]/z:compositeItem/z:moduleReference/z:moduleReferenceItem/@moduleItemId"/>
	
			there is no reason why the image __has_to_be__ attached only to one object, 
			see mulId 5802648 for an example although that might 
		-->
		<xsl:if test="count($objId) > 1">
			<xsl:message terminate="yes">
				<xsl:text>ERROR: objId is not UNIQUE</xsl:text>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="../@name"/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> ) </xsl:text>
				<xsl:value-of select="$objId"/>
			</xsl:message>
		</xsl:if>
		
		<!-- 
			if the image is not necessarily related to a meaningful object record, we 
			cant rely on extracting the right verwaltendeInstitution out of the object 
			item we're using verwaltendeInstittion below to get extract the ISIL. 
			Perhaps we should infer it another way, e.g. from the Institutionskürzel
				ISL-Fotos -> ISIL
			xsl:message>resourceSet</xsl:message
		-->
		<xsl:if test="count($verwaltendeInstitution) > 1">
			<xsl:message terminate="yes">
				<xsl:text>ERROR: verwaltendeInstitution is not UNIQUE</xsl:text>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="../@name"/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> ) </xsl:text>
				<xsl:value-of select="$verwaltendeInstitution"/>
			</xsl:message>
		</xsl:if>
		<xsl:variable name="object" select="/z:application/z:modules/z:module[@name = 'Object']/z:moduleItem[@id eq $objId]"/>
        <lido:resourceSet>
			<!--
				xsl:nummer nummeriert alle verknüpfteMM durch; das geht so nicht
				wo steht die Info, was ein Standardbild ist
			-->
            <xsl:attribute name="lido:sortorder">
				<xsl:variable name="sort" select="z:composite[@name='MulReferencesCre']/z:compositeItem/z:moduleReference[
					@name= 'MulObjectRef']/z:moduleReferenceItem/z:dataField[
					@name='SortLnu']/z:value"/>
				<!--xsl:message> ex objId 214875
					why I do get multiple SortLnu values sometimes; just using the first one atm
					<xsl:text>SORT:::</xsl:text>
					<xsl:value-of select="$sort"/>
				</xsl:message-->
				<xsl:choose>
					<xsl:when test="$sort[1] ne ''">
						<xsl:value-of select="$sort[1]"/>
					</xsl:when>
					<xsl:otherwise>10</xsl:otherwise>
				</xsl:choose>
            </xsl:attribute>
            <lido:resourceID>
				<xsl:attribute name="lido:label">Bild</xsl:attribute>
				<xsl:attribute name="lido:type">local</xsl:attribute>
				<xsl:attribute name="lido:source">SMB/ObjID/AssetID</xsl:attribute> 
				<xsl:value-of select="func:getISIL($verwaltendeInstitution)" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="$objId" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="z:systemField[@name='__id']/z:value" />
            </lido:resourceID>
			
            <!-- according to LIDO's pdf specification resourceID can have
                 attribute encodinganalog; according to xsd it can't have 
                 it. 
                <xsl:attribute name="encodinganalog">
                    <xsl:value-of select="pfadangabe"/>
                    <xsl:text>\</xsl:text>
                    <xsl:value-of select="dateiname"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="erweiterung"/>
                </xsl:attribute>
            -->
            <lido:resourceRepresentation>
                <xsl:attribute name="lido:type" xml:lang="en">
					<xsl:text>Provided image</xsl:text>
                </xsl:attribute>
				<xsl:variable name="id" select="normalize-space(z:systemField[@name='__id']/z:value)" />
                <lido:linkResource> 
					<xsl:analyze-string select="z:dataField[@name='MulOriginalFileTxt']" regex="\.(\w*)$">
						<xsl:matching-substring>
							<xsl:attribute name="lido:formatResource">
								<xsl:value-of select="func:vocmap-replace('formatResource', lower-case(regex-group(1)), 'mimetype')"/>
							</xsl:attribute>
							<!-- https://recherche.smb.museum/images/525075_2500x2500.jpg
							<xsl:value-of select="concat('https://recherche.smb.museum/images/',$id,'_2500x2500.jpg')"/>
							-->
							<xsl:value-of select="concat($id,'.',regex-group(1))"/>
						</xsl:matching-substring>
					</xsl:analyze-string>
                </lido:linkResource>
                    <!-- lido:resourceMeasurementsSet>
                        <lido:measurementType>width</lido:measurementType>
                        <lido:measurementUnit>pixel</lido:measurementUnit>
                        <lido:measurementValue>120</lido:measurementValue>
                    </lido:resourceMeasurementsSet -->
            </lido:resourceRepresentation>
			<lido:resourceType>
				<!-- 
					lido spec 1.0 "Example values: digital image, photograph, slide, videotape, Xray
					photograph, negative."
					no voc at http://terminology.lido-schema.org 20200301
					TODO
				-->
				<xsl:comment>type="europeana:type"</xsl:comment>
				<xsl:variable name="resType" select="z:vocabularyReference[@name='MulTypeVoc']/z:vocabularyReferenceItem/@name"/>
				<xsl:variable name="euType" select="func:vocmap-replace('MulTypeVgr',$resType, 'europeana:type')"/>

				<!-- 
					<xsl:message>
						resType: <xsl:value-of select="$resType"/> :: <xsl:value-of select="$euType"/>
					</xsl:message>
					default to image, so make sure we ALWAYS have a europeana:type
				-->
				<lido:term xml:lang="EN">
					<xsl:choose>
						<xsl:when test="$euType ne ''">
								<xsl:value-of select="$euType"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:text>image</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</lido:term>
			</lido:resourceType>
			<!-- 
				22.12.2021 
				Frank will das Feld nicht in LIDO haben, weil da teilweise Müll drin steht (?).
				14.2.2022 jetzt will er es wieder haben.
			-->
			<xsl:variable name="excluded" select="'182397'"/>
			<xsl:if test="not($object/z:moduleReference[@name='ObjObjectGroupsRef']/z:moduleReferenceItem[@moduleItemId = $excluded])">
				<xsl:message terminate="no">including Inhalt/Ansicht</xsl:message>
				<xsl:apply-templates select="z:dataField[@name='MulSubjectTxt']/z:value"/>
			</xsl:if>
			<xsl:apply-templates select="z:dataField[@name='MulDateTxt']/z:value"/>
			<!--Urheber-->
			<xsl:apply-templates mode="Urheber" select="z:moduleReference[@name='MulPhotographerPerRef']"/>
			
            <lido:rightsResource>
				<lido:rightsType>
					<lido:conceptID lido:source="CC"
					                lido:type="URI">http://creativecommons.org/by-nc-sa/4.0/</lido:conceptID>
					<lido:term lido:addedSearchTerm="no">Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)</lido:term>
				</lido:rightsType>                
				<lido:rightsHolder>
					<xsl:call-template name="legalBody">
						<xsl:with-param name="verwaltendeInstitution" select="$verwaltendeInstitution"/>
					</xsl:call-template>
                </lido:rightsHolder>

                <!-- 
                TODO: Not sure how FD wants the the creditline to be formated; 
                Currently, I am adapting credits in smb.digital.de, but not exactly. 
				Should be Staatliche Museen Berlin, Kunstbibliothek, Foto: Hans Kunz
                -->
                <lido:creditLine>
					<xsl:variable name="einrichtungKlein" select="normalize-space(substring-before($verwaltendeInstitution,','))"/>
					<!-- can also be SIM in case of MIM -->
					<xsl:variable name="einrichtungGroß" select="normalize-space(substring-after($verwaltendeInstitution,','))"/>
					<xsl:value-of select="$einrichtungGroß"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$einrichtungKlein"/>
                    <xsl:if test="z:moduleReference[@name='MulPhotographerPerRef']">
                        <xsl:text> / </xsl:text>
                        <xsl:value-of select="z:moduleReference[@name='MulPhotographerPerRef']/z:moduleReferenceItem/z:formattedValue"/>
                    </xsl:if>
					<xsl:if test="z:moduleReference[@name='MulPhotocreditTxt']">
						<xsl:message terminate="yes">
							<xsl:text>Untested CreditLine field from Digital Assets</xsl:text>
							<xsl:if test="z:moduleReference[@name='MulPhotocreditTxt'] ne ''">
								<xsl:text> - </xsl:text>
								<xsl:value-of select="z:dataField[@name='MulPhotocreditTxt']"/>
							</xsl:if>
						</xsl:message>
					</xsl:if>
                </lido:creditLine>
            </lido:rightsResource>
        </lido:resourceSet>
    </xsl:template>

    <xsl:template mode="Urheber" match="z:moduleReference[@name='MulPhotographerPerRef']">
		<!--xsl:message>
			<xsl:text>Urheber</xsl:text>
			<xsl:value-of select="z:moduleReferenceItem/z:formattedValue" />
		</xsl:message-->
		<lido:rightsResource>
			<lido:rightsType>
				<lido:term xml:lang="DE">Urheber</lido:term>
			</lido:rightsType>
			<lido:rightsHolder>
				<lido:legalBodyName>
					<lido:appellationValue>
						<xsl:value-of select="z:moduleReferenceItem/z:formattedValue" />
					</lido:appellationValue>
				</lido:legalBodyName>
			</lido:rightsHolder>
		</lido:rightsResource>
    </xsl:template>

	<!--
		inhaltAnsicht
		22.12.2021 Frank meint, dass die Kurator*innen nicht erwarten, dass inhaltAnsicht ausgegeben wird.
		14.2.2022 möchte Frank, resourceDescription doch wieder haben, aber nicht für bestimmte Exporte

		Problem in spec: resourceDescription does not allow xml:lang
	-->
    <xsl:template match="z:dataField[@name='MulSubjectTxt']/z:value">
		<lido:resourceDescription>
			<xsl:value-of select="."/>
		</lido:resourceDescription>
	</xsl:template>

    <!-- 
		was:anfertDat
        resourceDateTaken is part of xsd, given in LIDO examples, but not 
        part in pdf specification -->
    <xsl:template match="z:dataField[@name='MulDateTxt']/z:value">
        <lido:resourceDateTaken>
            <lido:displayDate>
                <xsl:value-of select="."/>
            </lido:displayDate>
        </lido:resourceDateTaken> 
    </xsl:template>
</xsl:stylesheet>
