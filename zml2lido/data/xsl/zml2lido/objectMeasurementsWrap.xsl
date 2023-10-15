<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

	<!-- 
	20230708 - new version with atomistic values in measurementsSet
	-->

	<xsl:template name="objectMeasurementsWrap">
		<lido:objectMeasurementsWrap>
			<xsl:apply-templates select="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem"/>
		</lido:objectMeasurementsWrap>
    </xsl:template>

	<xsl:template match="z:repeatableGroup[@name='ObjDimAllGrp']/z:repeatableGroupItem">
		<lido:objectMeasurementsSet>
			<xsl:if test="normalize-space(z:virtualField[@name='PreviewVrt']/z:value) != ''">
				<lido:displayObjectMeasurements xml:lang="de">
					<xsl:value-of select="normalize-space(z:moduleReference[
						@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue)"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="normalize-space(z:virtualField[@name='PreviewVrt']/z:value)"/>
				</lido:displayObjectMeasurements>
			</xsl:if>

			<xsl:variable name="type" select="z:moduleReference[
					@name='TypeDimRef'
				]/z:moduleReferenceItem/z:formattedValue"/>

			<xsl:variable name="unit" select="z:vocabularyReference[
					@name='UnitDdiVoc'
				]/z:vocabularyReferenceItem/z:formattedValue"/>
		
			<!--xsl:message>
				<xsl:text>DDD:</xsl:text>
				<xsl:value-of select="$type"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$unit"/>
			</xsl:message-->

			<lido:objectMeasurements>
				<xsl:choose>
					<!-- Circumference -->
					<xsl:when test="$type eq 'Umfang'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='CircumferenceNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- depth -->
					<xsl:when test="$type eq 'Tiefe'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>
		
					<!-- diameter -->
					<xsl:when test="$type = ('Durchmesser', 'Mündung', 'Öffnung',
						'Rahmenaußenmaß Durchmesser')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Durchmesser'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DiameterNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- diameter, depth -->
					<xsl:when test="$type eq 'Durchmesser x Tiefe'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Durchmesser'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DiameterNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- height -->
					<xsl:when test="$type = ('Höhe','Reliefhöhe')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>
					
					<!-- height, depth, width -->
					<xsl:when test="$type = ('Außenmaß', 'Gesamtmaß', 'Objektmaß')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- height, width, depth -->
					<xsl:when test="$type = ('Höhe x Breite x Tiefe', 'Installationsmaß')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>


					<!-- height, diameter -->
					<xsl:when test="$type eq 'Höhe x Durchmesser'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Durchmesser'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DiameterNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- height, weight -->
					<xsl:when test="$type = ('Auflagenkarton', 'Bemalte Bildfläche', 'Bildformat (Foto)', 
						'Bildmaß','Blattmaß', 'Glasmaß', 'height x width', 'Höhe x Breite', 
						'Höhe x Breite (aufgeschlagen)', 'Kartonformat (Foto)', 'Kartonformat', 'Papiermaß', 
						'Passepartout', 'Passepartoutmaß', 'Passepartout Standardformat', 'Plattenrand', 
						'Plattengröße (Foto)', 'Rahmenmaß', 'Rahmenaußenmaß', 'Stichhöhe', 'Tafelmaß', 
						'Wasserzeichenmaß', 'Zwischenkarton')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- height, width, thickness -->
					<xsl:when test="$type eq 'Höhe x Breite x Stärke'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='ThicknessNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>  

					<!-- height, depth, width -->
					<xsl:when test="$type = ('Höhe x Breite x Stärke', 'Maße Transport', 'Sockel')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Stärke'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>  

					<!-- hours:minuts:seconds -->
					<xsl:when test="$type = ('Dauer', 'Spieldauer')">
						<xsl:variable name="HHMMSS">
							<xsl:value-of select="format-number(../../../z:dataField[@name='HoursLnu']/z:value, '00')"/>
							<xsl:text>:</xsl:text>
							<xsl:value-of select="format-number(../../../z:dataField[@name='MinutesLnu']/z:value, '00')"/>
							<xsl:text>:</xsl:text>
							<xsl:value-of select="format-number(../../../z:dataField[@name='SecondsLnu']/z:value, '00')"/>
						</xsl:variable>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Durchmesser'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="$HHMMSS"/>
						</xsl:call-template>
					</xsl:when>

					<!-- length, diameter-->
					<xsl:when test="$type eq 'Rollenmaß'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Länge'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='LengthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Durchmesser'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DiameterNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- length, width-->
					<xsl:when test="$type eq 'Länge x Breite'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Länge'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='LengthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- length, width, depth-->
					<xsl:when test="$type eq 'Länge x Breite x Tiefe'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Länge'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='LengthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- length, width, height -->
					<xsl:when test="$type = ('Kistenmaß', 'Länge x Breite x Höhe')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Länge'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='LengthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- prefix, suffix-->
					<xsl:when test="$type eq 'Größe'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Prefix'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='PrefixTxt']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Suffix'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='SuffixTxt']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when> 

					<!-- prefix, height, width, suffix -->
					<xsl:when test="$type = ('format', 'Format')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Prefix'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='PrefixTxt']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Suffix'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='SuffixTxt']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!--speed-->
					<xsl:when test="$type = ('Geschwindigkeit', 'Geschwindigkeit (Band)', 
						'Geschwindigkeit (Schallplatte)', 'Geschwindigkeit (Walze)')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Geschwindigkeit'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='SpeedNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- text -->
					<xsl:when test="$type eq 'Andere'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Andere'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='TextTxt']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- thickness-->
					<xsl:when test="$type = ('Diaformat', 'Dicke', 'Durchmesser (mit Dicke)', 
						'Wandstärke','Wandungsstärke')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Dicke'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='ThicknessNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- unknown1 -->
					<xsl:when test="$type = ('Fläche', 'Sehnenlänge', 'Stichmaß')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='Unknown1Num']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- unknown1, unknown2-->
					<xsl:when test="$type eq 'Allgemein'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Andere'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='Unknown1Num']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Andere'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='Unknown2Num']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- unknown1, unknown2, unknown3 -->
					<xsl:when test="$type = ('Andere Maße','other dimensions')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Andere'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='Unknown3Num']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Andere'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='Unknown1Num']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Andere'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='Unknown2Num']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- volume -->
					<xsl:when test="$type eq 'Volumen'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='VolumeNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when> 

					<!-- weight -->
					<xsl:when test="$type = ('Gewicht', 'weight')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WeightNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when> 

					<!-- width -->
					<xsl:when test="$type = ('Länge', 'Breite', 'Schenkelbreite', 'Maßstab')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="$type"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- width, depth -->
					<xsl:when test="$type eq 'Breite x Tiefe'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- width, diameter-->
					<xsl:when test="$type eq 'Länge x Durchmesser'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Länge'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Durchmesser'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DiameterNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- width, height -->
					<xsl:when test="$type eq 'Breite x Höhe'">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- width, height, depth -->
					<xsl:when test="$type = ('Transportmaß', 'Verpackungsmaß')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='HeightNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Tiefe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='DepthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>

					<!-- width, length -->
					<xsl:when test="$type = ('Negativformat (Foto)', 'Montage')">
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Breite'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='WidthNum']/z:formattedValue"/>
						</xsl:call-template>
						<xsl:call-template name="measurementsSet">
							<xsl:with-param name="type" select="'Höhe'"/>
							<xsl:with-param name="unit" select="$unit"/>
							<xsl:with-param name="value" select="z:dataField[@name='LengthNum']/z:formattedValue"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$type = ('Kartierung Wasserzeichen')">
						<xsl:message>WARNING: empty measurement type IGNORING </xsl:message>
						<xsl:value-of select="$type"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="../../../@name"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="../../@id"/>
					</xsl:when>
					<xsl:when test="not(z:moduleReference[@name='TypeDimRef'])">
						<xsl:message>WARNING: empty measurement type IGNORING </xsl:message>
						<xsl:value-of select="../../../@name"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="../../@id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">
							<xsl:text>ERROR: Unknown Measurement Type: </xsl:text>
							<xsl:value-of select="$type"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="../../../@name"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="../../@id"/>
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>

				<!-- Do we always want extentMeasurements or only sometimes?-->
				<xsl:if test="$type = ('Auflagenkarton', 'Außenmaß', 'Bemalte Bildfläche', 'Bildformat (Foto)', 
					'Bildmaß', 'Blattmaß', 'Dauer', 'Gesamtmaß', 'Glasmaß', 'Größe', 'Kartonformat (Foto)', 
					'Kartonformat', 'Kistenmaß', 'Maßstab', 'Montage', 'Mündung',
					'Negativformat (Foto)',  'Öffnung', 'Plattengröße (Foto)', 'Passepartout', 'Passepartoutmaß', 
					'Passepartout Standardformat', 
					'Rahmenmaß', 'Rahmenaußenmaß', 'Rahmenaußenmaß Durchmesser', 'Rollenmaß', 'Sockel', 
					'Stichhöhe', 'Tafelmaß', 'Transportmaß', 'Verpackungsmaß')">
					<lido:extentMeasurements>
						<xsl:attribute name="xml:lang">
							<xsl:value-of select="z:moduleReference[
								@name='TypeDimRef']/z:moduleReferenceItem/z:formattedValue/@language"/>
						</xsl:attribute>
							<xsl:value-of select="normalize-space($type)"/>
					</lido:extentMeasurements>
				</xsl:if>
			</lido:objectMeasurements>
		</lido:objectMeasurementsSet>
	</xsl:template>

	<xsl:template name="measurementsSet">
		<xsl:param name="type"/>
		<xsl:param name="unit"/>
		<xsl:param name="value"/>
		<xsl:variable name="lang" select="z:moduleReference[
			@name='TypeDimRef'
		]/z:moduleReferenceItem/z:formattedValue/@language[1]"/>
		<!--xsl:message>
			<xsl:text>DDDDD:</xsl:text>
			<xsl:value-of select="$lang"/>
		</xsl:message-->
		<lido:measurementsSet>
			<lido:measurementType>
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
				<xsl:value-of select="$type"/>
			</lido:measurementType>
			<lido:measurementUnit>
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
				<xsl:value-of select="$unit"/>
			</lido:measurementUnit>
			<lido:measurementValue>
				<xsl:attribute name="xml:lang">
					<xsl:value-of select="$lang"/>
				</xsl:attribute>
				<xsl:value-of select="$value"/>
			</lido:measurementValue>
		</lido:measurementsSet>
	</xsl:template>
</xsl:stylesheet>