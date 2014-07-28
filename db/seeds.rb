User.create(meta: Admin.create!, email: "foo@bar.com", password: "asdfasdf", password_confirmation: "asdfasdf")

cats = Category.create(name: 'CAT1'), Category.create(name: 'CAT2')
tags = Tag.create(name: 'TAG1'), Tag.create(name: 'TAG2'), Tag.create(name: 'TAG3'), Tag.create(name: 'TAG4')

1000.times do 
  cat = cats[rand cats.length]
  tag = tags.slice(*[rand(tags.length), rand(tags.length)].sort).map {|t| t.name }
  f = Fabric.create(width: 10, category: cat, tags: tag)

  5.times do |i|
    color = "%06x" % (rand * 0xffffff)
    FabricVariant.create(fabric: f, color: color, position: i)
  end
end
