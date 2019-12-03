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
  (Date.today.. Date.today+1.week).each do |d|
    block = [6, 8, 10, 12, 14, 16, 18, 20]
    block.each do |b|
      Schedule.create(day: d, hour: b, room_id: 1)
    end
  end
end
