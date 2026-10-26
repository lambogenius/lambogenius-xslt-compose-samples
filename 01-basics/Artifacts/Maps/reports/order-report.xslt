<?xml version="1.0" encoding="utf-8"?>
<!-- Order to an HTML page. With method="html" the action returns text/html. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes"/>

  <xsl:param name="title" select="'Order'"/>

  <xsl:template match="/Order">
    <html>
      <head>
        <title><xsl:value-of select="$title"/>: <xsl:value-of select="normalize-space(Number)"/></title>
        <style>
          body { font-family: system-ui, sans-serif; margin: 2rem; }
          table { border-collapse: collapse; }
          th, td { border: 1px solid #ccc; padding: .3rem .6rem; }
          td.n { text-align: right; }
        </style>
      </head>
      <body>
        <h1><xsl:value-of select="$title"/>: <xsl:value-of select="normalize-space(Number)"/></h1>
        <p>Customer <xsl:value-of select="CustomerId"/>, ship to <xsl:value-of select="ShipTo/Name"/>, <xsl:value-of select="ShipTo/City"/></p>
        <table>
          <tr><th>SKU</th><th>Description</th><th>Qty</th><th>Unit price</th></tr>
          <xsl:for-each select="Lines/Line">
            <tr>
              <td><xsl:value-of select="normalize-space(Sku)"/></td>
              <td><xsl:value-of select="Description"/></td>
              <td class="n"><xsl:value-of select="Quantity"/></td>
              <td class="n"><xsl:value-of select="format-number(UnitPrice, '0.00')"/></td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
