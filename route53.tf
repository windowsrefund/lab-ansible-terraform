resource "aws_route53_delegation_set" "main" {}

resource "aws_route53_zone" "primary" {
  name              = var.route53_primary_zone
  delegation_set_id = aws_route53_delegation_set.main.id
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.route53_primary_zone
  type    = "A"
  ttl     = "300"
  records = ["18.234.162.127"]
}

resource "aws_route53_record" "wiki" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "wiki"
  type    = "A"
  ttl     = "300"
  records = ["18.234.162.127"]
}

resource "aws_route53_record" "mail" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.route53_primary_zone
  type    = "MX"
  ttl     = "300"
  records = ["10 mail.nycpatriot.org"]
}
