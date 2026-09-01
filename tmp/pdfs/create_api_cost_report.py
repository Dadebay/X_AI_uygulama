from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

OUT = "/Users/dadebay/Developer/apps/projects/x_ai_uygulama/output/pdf/pulse_sports_api_maliyet_raporu.pdf"
pdfmetrics.registerFont(TTFont("ReportSans", "/System/Library/Fonts/Supplemental/Arial.ttf"))
pdfmetrics.registerFont(TTFont("ReportSansBold", "/System/Library/Fonts/Supplemental/Arial Bold.ttf"))

doc = SimpleDocTemplate(OUT, pagesize=A4, rightMargin=15*mm, leftMargin=15*mm, topMargin=14*mm, bottomMargin=13*mm)
styles = getSampleStyleSheet()
title = ParagraphStyle("title", parent=styles["Title"], fontName="ReportSansBold", fontSize=19, leading=23, textColor=colors.HexColor("#16251D"), spaceAfter=4)
sub = ParagraphStyle("sub", parent=styles["Normal"], fontName="ReportSans", fontSize=8.5, leading=11, textColor=colors.HexColor("#57635C"), spaceAfter=11)
h = ParagraphStyle("h", parent=styles["Heading2"], fontName="ReportSansBold", fontSize=12, leading=15, textColor=colors.HexColor("#16251D"), spaceBefore=7, spaceAfter=6)
body = ParagraphStyle("body", parent=styles["Normal"], fontName="ReportSans", fontSize=8.4, leading=11, textColor=colors.HexColor("#29352E"))
small = ParagraphStyle("small", parent=body, fontSize=7.4, leading=9, textColor=colors.HexColor("#57635C"))
note = ParagraphStyle("note", parent=body, fontSize=8.2, leading=10.5, backColor=colors.HexColor("#EEF6F0"), borderColor=colors.HexColor("#B7D9C0"), borderWidth=0.5, borderPadding=7)

def P(text, style=body): return Paragraph(text, style)

story = [
    P("Pulse Sports - API seçenekleri ve aylık maliyet", title),
    P("13 Ağustos 2026 | Fiyatlar sağlayıcıların açık fiyat sayfalarından alınmıştır; kur, KDV ve kurumsal teklif hariçtir.", sub),
    P("Kısa karar", h),
    P("<b>Başlangıç önerisi:</b> futbol + diğer sporlar için önce <b>API-Football / API-Sports ($19/ay)</b> ile pilot yapın. Çok-spor ekranları için veri yeterliliğini test edin. Geniş çok-spor canlı skor ihtiyacı oluşursa <b>TheSportsDB ($9/ay)</b> ek/alternatif; yüksek doğruluk, canlı olay ve kurumsal kapsam gerekirse Goalserve teklifine geçin.", note),
    Spacer(1, 8),
    P("1. Spor verisi API'leri", h),
]

sport_data = [
    [P("Sağlayıcı", body), P("Kapsam", body), P("Aylık maliyet", body), P("Uygunluk", body)],
    [P("API-Football / API-Sports"), P("Futbol; API-Sports hesabında basketbol, F1, rugby, voleybol vb. ürünler"), P("$0 / $19 / $29 / $39<br/><font size=7>(100 / 7.500 / 75.000 / 150.000 istek-gün)</font>"), P("En iyi başlangıç maliyeti. Önce hedef spor ve lig kapsamını dene.")],
    [P("TheSportsDB"), P("Çok spor: futbol, NFL, NBA, MLB, NHL ve geniş etkinlik/ekip verisi"), P("$0 veya $9/ay<br/><font size=7>Premium: 100 istek/dk, 2 dk canlı skor</font>"), P("Ekonomik çok-spor MVP. Mağazaya çıkış için ücretli plan gerekir.")],
    [P("Sportmonks"), P("Futbol; ayrıca kriket ve Formula 1"), P("EUR 29 / 99 / 249<br/><font size=7>5 / 30 / 120 lig</font>"), P("Futbol derinliği ve seçilmiş lig modeli için.")],
    [P("Goalserve"), P("20+ spor; canlı skor, istatistik, oran; JSON/XML"), P("$800/ay tüm sporlar<br/><font size=7>Futbol canlı skor: $150/ay</font>"), P("Kurumsal canlı veri. MVP için pahalı.")],
]
t = Table(sport_data, colWidths=[35*mm, 59*mm, 38*mm, 48*mm], repeatRows=1)
t.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.HexColor("#16251D")), ("TEXTCOLOR", (0,0), (-1,0), colors.white),
    ("FONTNAME", (0,0), (-1,0), "ReportSansBold"), ("FONTSIZE", (0,0), (-1,-1), 7.4),
    ("LEADING", (0,0), (-1,-1), 9.3), ("GRID", (0,0), (-1,-1), 0.3, colors.HexColor("#C9D2CC")),
    ("VALIGN", (0,0), (-1,-1), "TOP"), ("LEFTPADDING", (0,0), (-1,-1), 5), ("RIGHTPADDING", (0,0), (-1,-1), 5),
    ("TOPPADDING", (0,0), (-1,-1), 5), ("BOTTOMPADDING", (0,0), (-1,-1), 5),
    ("BACKGROUND", (0,1), (-1,-1), colors.HexColor("#F7F9F7")),
]))
story += [t, Spacer(1, 8), P("Tahmini spor veri bütçesi", h)]

budget_data = [
    [P("Senaryo"), P("İçerik"), P("Aylık veri maliyeti")],
    [P("MVP"), P("Futbol odaklı; temel fikstür, skor, puan durumu"), P("$19 (API-Football Pro)")],
    [P("MVP + çok spor"), P("Futbol + temel diğer spor katalog/canlı skor"), P("$9-$39<br/><font size=7>TheSportsDB Premium veya API-Sports planı</font>")],
    [P("Profesyonel"), P("Derin futbol istatistikleri, seçili ligler"), P("EUR 29+ (Sportmonks)")],
    [P("Kurumsal canlı veri"), P("20+ spor, yoğun canlı veri / oran"), P("$800+ (Goalserve)")],
]
bt = Table(budget_data, colWidths=[40*mm, 91*mm, 49*mm])
bt.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.HexColor("#DDEFE1")), ("FONTNAME", (0,0), (-1,0), "ReportSansBold"),
    ("GRID", (0,0), (-1,-1), 0.3, colors.HexColor("#C9D2CC")), ("VALIGN", (0,0), (-1,-1), "TOP"),
    ("FONTSIZE", (0,0), (-1,-1), 8), ("LEFTPADDING", (0,0), (-1,-1), 5), ("RIGHTPADDING", (0,0), (-1,-1), 5),
    ("TOPPADDING", (0,0), (-1,-1), 5), ("BOTTOMPADDING", (0,0), (-1,-1), 5),
]))
story += [bt, Spacer(1, 7), P("2. X için post, zamanlama ve silme", h)]
story += [P("<b>Resmî çözüm:</b> X API v2. Post oluşturma, silme ve hesap yetkilendirmesi mümkün. X API'nin standart gönderi zamanlama endpoint'i yok; zamanlamayı kendi minimal uygulamamızda (veritabanı + cron/queue) tutar, zamanı gelince <b>POST /2/tweets</b> çağırırız. Silmede <b>DELETE /2/tweets/:id</b> kullanılır.", body), Spacer(1,5)]

x_data = [
    [P("İşlem", body), P("Resmî X API ücreti", body), P("Örnek aylık maliyet", body)],
    [P("Post oluşturma"), P("$0.015 / post"), P("100 post: $1.50 | 1.000 post: $15")],
    [P("URL içeren post"), P("$0.200 / post"), P("100 post: $20 | 1.000 post: $200")],
    [P("Post silme"), P("$0.010 / istek"), P("100 silme: $1 | 1.000 silme: $10")],
    [P("Zamanlama"), P("X'te ayrı endpoint yok"), P("Kendi cron/queue: küçük sunucu yaklaşık $0-$10/ay")],
]
xt = Table(x_data, colWidths=[42*mm, 55*mm, 83*mm])
xt.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.HexColor("#16251D")), ("TEXTCOLOR", (0,0), (-1,0), colors.white),
    ("FONTNAME", (0,0), (-1,0), "ReportSansBold"), ("GRID", (0,0), (-1,-1), 0.3, colors.HexColor("#C9D2CC")),
    ("VALIGN", (0,0), (-1,-1), "TOP"), ("FONTSIZE", (0,0), (-1,-1), 8),
    ("LEFTPADDING", (0,0), (-1,-1), 5), ("RIGHTPADDING", (0,0), (-1,-1), 5), ("TOPPADDING", (0,0), (-1,-1), 5), ("BOTTOMPADDING", (0,0), (-1,-1), 5),
    ("BACKGROUND", (0,1), (-1,-1), colors.HexColor("#F7F9F7")),
]))
story += [xt, Spacer(1,7), P("Önerilen minimal yapı", h), P("<b>1.</b> X Developer Console'da uygulama oluştur, kredi yükle. <b>2.</b> Her X hesabını OAuth ile bağla. <b>3.</b> Uygulamada taslak + scheduled_at + durum tut. <b>4.</b> Dakikada bir çalışan görev yalnızca zamanı gelen postu yayınlasın. <b>5.</b> Yayınlanan post ID'sini sakla; silme işlemi bu ID ile yapılır. Bu yöntem X kurallarına uygun ve düşük maliyetlidir.", body), Spacer(1,8), P("Kaynaklar: api-football.com/pricing | thesportsdb.com/docs_pricing.php | sportmonks.com/football-api/plans-pricing | goalserve.com/.../prices | docs.x.com/x-api/getting-started/pricing. Fiyatlar değişebilir; satın almadan önce sağlayıcının ödeme ekranında doğrulayın.", small)]

doc.build(story)
print(OUT)
