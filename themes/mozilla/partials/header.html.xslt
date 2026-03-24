<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:planet="http://planet.intertwingly.net/"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="atom planet xhtml">
  <xsl:template name="header">
    <div id='utility'>
      <p><strong>Looking For</strong></p>
      <ul>
        <li><a href='https://www.mozilla.org/'>mozilla.org</a></li>
        <li><a href='https://wiki.mozilla.org/'>Wiki</a></li>
        <li><a href='https://developer.mozilla.org/'>Developer Center</a></li>
        <li><a href='http://www.firefox.com/'>Firefox</a></li>
        <li><a href='http://www.getthunderbird.com/'>Thunderbird</a></li>
      </ul>
    </div>

    <div id='header'>
      <div id='dino'>
        <h1>
          <a href='/' title='Back to home page'>
            <xsl:value-of select='atom:title'/>
          </a>
        </h1>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>
