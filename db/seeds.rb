User.create(email: "dcrute25@hotmail.com", lname: "cruté", fname: "darien")
@id = User.last.id
Profile.create(bday: "1988-02-25", username: "dcrute", password: "AdminPassword1", hometown: "bronx", user_id: @id, approved: true, admin: true)