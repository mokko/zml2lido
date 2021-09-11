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
            <lido:resourceWrap>
                <xsl:apply-templates mode="resourceWrap" select="$verknüpfteMM" />
            </lido:resourceWrap>
    </xsl:template>

    <xsl:template mode="resourceWrap" match="/z:application/z:modules/z:module[@name = 'Multimedia']/z:moduleItem">
		<xsl:variable name="objId" select="z:composite[@name eq 'MulReferencesCre']/z:compositeItem/z:moduleReference[1]/z:moduleReferenceItem/@moduleItemId"/>
		<xsl:variable name="verwaltendeInstiution" select="/z:application/z:modules/z:module[
			@name = 'Object']/z:moduleItem[@id eq $objId]/z:moduleReference[
			@name='ObjOwnerRef']/z:moduleReferenceItem/z:formattedValue"/>
		<!--xsl:message>resourceSet</xsl:message-->
        <lido:resourceSet>
			<!--
				xsl:nummer nummeriert alle verknüpfteMM durch; das geht so nicht
				wo steht die Info, was ein Standardbild ist
			-->
            <xsl:attribute name="lido:sortorder">
                <xsl:number/> <!--todo-->
            </xsl:attribute>
            <lido:resourceID>
				<xsl:attribute name="lido:label">Bild</xsl:attribute>
				<xsl:attribute name="lido:type">mulId</xsl:attribute>
				<xsl:attribute name="lido:source">SMB/ObjID/AssetID</xsl:attribute> 
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
                <xsl:attribute name="lido:type" xml:lang="EN">
					<xsl:analyze-string select="z:dataField[@name='MulOriginalFileTxt']" regex=".(\w*)$">
						<xsl:matching-substring>
							<!--xsl:message>
								<xsl:text>EXT</xsl:text>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:message-->
							<xsl:choose>
								<xsl:when test="lower-case(regex-group(1)) eq 'jpg'">
									<xsl:text>Preview Representation</xsl:text>
								</xsl:when>
								<xsl:when test="lower-case(regex-group(1)) eq 'tif' or lower-case(regex-group(1)) eq 'tiff' ">
									<xsl:text>Provided Representation</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Preview Representation</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:matching-substring>
					</xsl:analyze-string>
                </xsl:attribute>
				<xsl:variable name="id" select="normalize-space(z:systemField[@name='__id']/z:value)" />
                <lido:linkResource> 
					<xsl:analyze-string select="z:dataField[@name='MulOriginalFileTxt']" regex=".(\w*)$">
						<xsl:matching-substring>
							<xsl:attribute name="lido:formatResource">
								<xsl:value-of select="lower-case(regex-group(1))"/>
							</xsl:attribute>
							<!-- xsl:text>../../pix2/xsl:text-->
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
				<xsl:comment>@type='europeana:type'</xsl:comment>
				<xsl:variable name="resType" select="z:vocabularyReference[@name='MulTypeVoc']/z:vocabularyReferenceItem/@name"/>
				<lido:term xml:lang="EN">
					<xsl:value-of select="func:vocmap-replace('MulTypeVgr',$resType, 'europeana:type')"/>
				</lido:term>
				
			
			</lido:resourceType>
			<xsl:apply-templates select="z:dataField[@name='MulSubjectTxt']/z:value"/>
			<xsl:apply-templates select="z:dataField[@name='MulDateTxt']/z:value"/>
			<!--Urheber-->
			<xsl:apply-templates mode="Urheber" select="z:moduleReference[@name='MulPhotographerPerRef']"/>
			
            <lido:rightsResource>
                <lido:rightsType>
                    <lido:term>Nutzungsrechte</lido:term>
                </lido:rightsType>
                <lido:rightsHolder>
                    <lido:legalBodyName>
                        <lido:appellationValue>
                            <xsl:text>Staatliche Museen zu Berlin, Preußischer Kulturbesitz</xsl:text>
                        </lido:appellationValue>
                    </lido:legalBodyName>
                </lido:rightsHolder>

                <!-- 
                TODO: Not sure how FD wants the the creditline to be formated; 
                Currently, I am adapting credits in smb.digital.de, but not exactly. 
                -->
                <lido:creditLine>
                    <xsl:if test="z:moduleReference[@name='MulPhotographerPerRef']">
                        <xsl:text>Foto: </xsl:text>
                        <xsl:value-of select="z:moduleReference[@name='MulPhotographerPerRef']/z:moduleReferenceItem/z:formattedValue"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
					<xsl:value-of select="$verwaltendeInstiution"/>
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

	<!--inhaltAnsicht-->
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
