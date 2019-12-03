# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
# (3.months.ago.to_date..Date.current)
# times do |t|
if User.count < 2
  User.create(name: "Ivan Silva", email: "i.so@gmail.com", phone: "3168219400", rol: 1)
  User.create(name: "Zorro master", email: "z@gmail.com", phone: "3502633499", rol: 2)
  User.create(name: "Suscriptor test", email: "test@gmail.com", phone: "3145678400", rol: 0)
end

if Suscription.count < 2
  Suscription.create(name: 6, status: true, hours: 3, observations: "Suscription de prueba para School", rooms: "1,2,4,8", user_id: 3)
end

if Room.count < 5
  7.times do |i|
    Room.create(name: "Cabina #{i+1}")
  end
  Room.create(name: "Estudio 1")
end


if Schedule.count < 1
  Schedule.create(name: "2019-12-09 06:00:00", room_id: 1)
end
