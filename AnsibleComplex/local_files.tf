resource "local_file" "items_to_template" {
  content = templatefile("details.tpl",
    {
      client01 = aws_instance.public-web-server-1.public_ip
      client02 = aws_instance.public-web-server-2.public_ip
      # client03 = aws_instance.public-web-server-3.public_ip
      # client01_private = aws_instance.private-web-server-1.private_ip
  })
  filename = "invfile"
}
