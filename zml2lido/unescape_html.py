import html
from bs4 import BeautifulSoup
import re


def unescape_html(raw_text: str | None) -> str | None:
    """
    For MuseumPlus's so-called HTML fields. unescape and convert so-called html to
    correct text may include line feeds.

    How to deal with stupid input? it may return None
    """
    if raw_text is None:
        return None
    else:
        if not isinstance(raw_text, str):
            raise TypeError("raw_text has bad type")

    raw_text2 = raw_text.strip()
    if raw_text2 == "":
        return ""
    elif "&lt;" in raw_text2:
        escaped_html = html.unescape(raw_text2)
        soup = BeautifulSoup(escaped_html, "html.parser")
        for br in soup.find_all("br", recursive=True):
            br.replace_with("\n\n")

        text = soup.get_text(separator=" ", strip=False)  # strip at beginning and end.
        clean_text = re.sub(r"\n\n\s+", "\n\n", text)  # trim spaces after \n\n
        # clean_text = re.sub(r'[^\S\n]+', ' ', text)  # Inline spaces
        return clean_text
    else:
        return raw_text2


if __name__ == "__main__":
    # debugging
    # from 1020789
    raw_text = """
    &lt;div&gt;[...] Hier verwendete die Künstlerin neben dem schwarzen Zeichenstein einen braunen Tonstein. Um die Darstellung aufzuhellen und Lichteffekte zu erreichen, wurden aus letzterem Linien ausgekratzt. Darüberhinaus sind auch an der Zeichnung selbst kleine Korrekturen zum Auflichten von Gesicht, Haaren und Hintergrund vorgenommen&lt;/div&gt;&lt;div&gt;worden. Die [...] Verwendung einer weißen Strichplatte "zum Aufsetzen der weissen Lichter" [August Klipstein 1955] ließ sich bisher bei keinem der bekannt gewordenen Drucke nachweisen. Das nur in wenigen Exemplaren verbreitete Selbstbildnis ist ein wichtiges Beispiel für die malerische Seite des Frühwerkes von Käthe Kollwitz. Ihr Bemühen um die farbige Gestaltung ihrer Druckgraphik, das sich in den verwendeten&lt;/div&gt;&lt;div&gt;Druckfarben und Papieren sowie in nachträglichen Übermalungen zeigt, setzt um die Jahrhundertwende ein, geht aber nach 1903 deutlich zurück und verschwindet im Spätwerk ganz. Da Kollwitz ursprünglich Malerin werden wollte und auch als&lt;/div&gt;&lt;div&gt;solche ausgebildet wurde, orientierte sie sich zunächst stark an der Malerei.&lt;/div&gt;&lt;div&gt;&lt;br&gt;&lt;/div&gt;&lt;div&gt;(Text: Sigrid Achenbach, Käthe Kollwitz (1867-1945). Zeichnungen und seltene Druckgraphik im Berliner Kupferstichkabinett, Ausst.-Kat. Kupferstichkabinett, Staatliche Museen zu Berlin - Preußischer Kulturbesitz, Berlin 1995, S. 29, Kat.-Nr. 12)&lt;/div&gt;
    """

    clean_text = unescape_html(raw_text)
    print(clean_text)
