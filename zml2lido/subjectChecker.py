"""

subject checker - write an excel file for subjects that dont have URL

We walk thru a set of chunk files in generic ZML
For each chunk
        lookup subjects and see if they are vocmap.xml
        if not write that term into a Excel file
        making a new file if no excel exists and appending an existing one

NOTES


QUESTIONS
1.
Looping thru chunk files is something I tend to need from multiple scrits. Where should that
code live?
2.
I have similar functionality in the xslt; now I re-implement that in the Python.
Does that really make sense?

WARNING: vocmap-replace-lax returns EMPTY ON Fotografie FROM subjects (aatUri)

ZML
z:vocabularyReference[@name = 'KeywordProjectVoc']

4 Subject Entries
- Fotografie (in: Europeana-Fashion)
- Papier (in Europeana-Fashion)
- Herrenbekleidung (in Europeana-Fashion)
- Jacke (in Europeana-Fashion)

Was sind die IDs in European-Fashion für diese Terme?

        <repeatableGroup name="ObjIconographyGrp" size="4">
          <repeatableGroupItem id="43066583">
            <vocabularyReference name="KeywordProjectVoc" id="61671" instanceName="ObjIconographyKeywordProjectVgr">
              <vocabularyReferenceItem id="4254984" name="Europeana-Fashion##Modeobjekte##Visuelle und verbale Kommunikation##analoge Medien##Fotografie">
                <formattedValue language="de">Fotografie</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
            <vocabularyReference name="TypeVoc" id="61673" instanceName="ObjIconographyTypeVgr">
              <vocabularyReferenceItem id="4399651" name="Europeana Fashion">
                <formattedValue language="de">Europeana Fashion</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
          </repeatableGroupItem>
          <repeatableGroupItem id="43066584">
            <vocabularyReference name="KeywordProjectVoc" id="61671" instanceName="ObjIconographyKeywordProjectVgr">
              <vocabularyReferenceItem id="4254558" name="Europeana-Fashion##Material##Materialien zur Dekoration, Besatz und technischen Ausrüstung##Werkstoffe pflanzlichen Ursprungs##Papier">
                <formattedValue language="de">Papier</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
            <vocabularyReference name="TypeVoc" id="61673" instanceName="ObjIconographyTypeVgr">
              <vocabularyReferenceItem id="4399651" name="Europeana Fashion">
                <formattedValue language="de">Europeana Fashion</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
          </repeatableGroupItem>
          <repeatableGroupItem id="43066585">
            <vocabularyReference name="KeywordProjectVoc" id="61671" instanceName="ObjIconographyKeywordProjectVgr">
              <vocabularyReferenceItem id="4254883" name="Europeana-Fashion##Modeobjekte##Kleidung##trägerspezifische Kleidung##Herrenbekleidung">
                <formattedValue language="de">Herrenbekleidung</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
            <vocabularyReference name="TypeVoc" id="61673" instanceName="ObjIconographyTypeVgr">
              <vocabularyReferenceItem id="4399651" name="Europeana Fashion">
                <formattedValue language="de">Europeana Fashion</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
          </repeatableGroupItem>
          <repeatableGroupItem id="43066586">
            <vocabularyReference name="KeywordProjectVoc" id="61671" instanceName="ObjIconographyKeywordProjectVgr">
              <vocabularyReferenceItem id="4254894" name="Europeana-Fashion##Modeobjekte##Kleidung##wichtigste Kleidungsstücke##Überbekleidung##Jacke">
                <formattedValue language="de">Jacke</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
            <vocabularyReference name="TypeVoc" id="61673" instanceName="ObjIconographyTypeVgr">
              <vocabularyReferenceItem id="4399651" name="Europeana Fashion">
                <formattedValue language="de">Europeana Fashion</formattedValue>
              </vocabularyReferenceItem>
            </vocabularyReference>
          </repeatableGroupItem>
        </repeatableGroup>


LIDO when the mapping exists
                  <lido:subject>
                     <lido:subjectConcept>
                        <lido:conceptID lido:type="local" lido:source="SMB/RIA">4254882</lido:conceptID>
                        <lido:conceptID lido:type="URI" lido:source="aat">http://vocab.getty.edu/aat/300379344</lido:conceptID>
                        <lido:conceptID lido:type="URI" lido:source="europeanafashion">http://thesaurus.europeanafashion.eu/thesaurus/10434</lido:conceptID>
                        <lido:term xml:lang="de">Damenbekleidung</lido:term>
                     </lido:subjectConcept>
                  </lido:subject>


"""
