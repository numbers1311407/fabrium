# User.create(meta: Admin.create!, email: "foo@bar.com", password: "asdfasdf", password_confirmation: "asdfasdf", confirmed_at: Time.now.utc)

# cats = Category.create(name: 'CAT1'), Category.create(name: 'CAT2')
# tags = Tag.create(name: 'TAG1'), Tag.create(name: 'TAG2'), Tag.create(name: 'TAG3'), Tag.create(name: 'TAG4')
# mills = Mill.create(name: 'MILL1'), Mill.create(name: 'MILL2'), Mill.create(name: 'MILL3')

cats = Category.all.to_a
tags = Tag.all.to_a
mills = Mill.all.to_a

files = Dir.glob("seeds/**/**.jpg") 

uploader = Dragonfly.app

Dir["./seeds/*"].each do |path|
  cat = cats[rand cats.length]
  mill = mills[rand mills.length]
  tag = tags.slice(*[rand(tags.length), rand(tags.length)].sort).map(&:name)
  item_number = File.basename(path)

  f = Fabric.create({
    item_number: item_number,
    width: 5 + rand(10),
    weight: 5 + rand(10),
    category: cat, 
    tags: tag,
    mill: mill
  })

  Dir.glob("#{path}/*").each.with_index do |image, i|
    colors = Miro::DominantColors.new(image)
    color = colors.to_hex[0]

    image_file = uploader.fetch_file(image)
    image_crop = "100x100%;200x200#nw"

    m = FabricVariant.create({
      item_number: "#{item_number}-#{i+1}",
      fabric: f, 
      color: color, 
      position: i, 
      image: image_file, 
      image_crop: image_crop
    })
  end
end
