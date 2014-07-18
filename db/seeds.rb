User.create(email: "dcrute25@hotmail.com", lname: "cruté", fname: "darien")
@id = User.last.id
Profile.create(bday: "1988-02-25", username: "dcrute", password: "AdminPassword1", hometown: "bronx", user_id: @id, approved: true, admin: true)
Post.create(user_id: @id, string_data: "Welcome to the Cruté Family site!")
User.create(email: "chipper62@aol.com", lname: "westby", fname: "charles")
@id = User.last.id
Profile.create(bday: "1984-06-02", username: "cnotes", password: "Password1", hometown: "bronx", user_id: @id, approved: true, admin: false)