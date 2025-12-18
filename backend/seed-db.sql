-- Seed database with 10 test users with complete profiles

-- Insert 10 users with complete profiles
-- Photos stored as plain base64 strings (without data URL prefix for Flutter compatibility)
INSERT INTO users (phone, email, name, gender, looking_for, bio, birthdate, photos, tags, credits, is_verified) VALUES
('9876543210', 'priya.sharma@email.com', 'Priya Sharma', 'female', 'male', 'Coffee addict ☕ | Travel enthusiast 🌍 | Bookworm 📚', '1995-03-15', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['coffee', 'travel', 'books', 'foodie'], 100, true),
('9876543211', 'rahul.verma@email.com', 'Rahul Verma', 'male', 'female', 'Fitness freak 💪 | Tech geek 💻 | Foodie 🍕', '1993-07-20', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['fitness', 'tech', 'food', 'gaming'], 150, true),
('9876543212', 'ananya.singh@email.com', 'Ananya Singh', 'female', 'male', 'Artist 🎨 | Dog lover 🐕 | Adventure seeker 🏔️', '1996-11-08', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['art', 'dogs', 'adventure', 'hiking'], 80, true),
('9876543213', 'arjun.patel@email.com', 'Arjun Patel', 'male', 'female', 'Entrepreneur | Music lover 🎵 | Motorcycle enthusiast 🏍️', '1992-05-12', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['music', 'bikes', 'business', 'travel'], 200, true),
('9876543214', 'sneha.reddy@email.com', 'Sneha Reddy', 'female', 'male', 'Yoga instructor 🧘 | Nature lover 🌿 | Minimalist', '1997-09-25', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['yoga', 'nature', 'wellness', 'meditation'], 120, true),
('9876543215', 'vikram.kumar@email.com', 'Vikram Kumar', 'male', 'female', 'Software engineer 👨‍💻 | Gamer 🎮 | Anime fan', '1994-01-30', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['coding', 'gaming', 'anime', 'tech'], 90, true),
('9876543216', 'ishita.joshi@email.com', 'Ishita Joshi', 'female', 'male', 'Fashion blogger 👗 | Wine enthusiast 🍷 | Beach bum 🏖️', '1995-06-18', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['fashion', 'wine', 'beach', 'shopping'], 110, true),
('9876543217', 'rohan.mehta@email.com', 'Rohan Mehta', 'male', 'female', 'Photographer 📸 | Traveler ✈️ | Craft beer lover 🍺', '1991-12-05', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['photography', 'travel', 'beer', 'adventure'], 180, true),
('9876543218', 'kavya.nair@email.com', 'Kavya Nair', 'female', 'male', 'Dentist 🦷 | Dancer 💃 | Foodie with a sweet tooth 🍰', '1996-04-22', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['dance', 'food', 'desserts', 'music'], 95, true),
('9876543219', 'aditya.chopra@email.com', 'Aditya Chopra', 'male', 'female', 'Investment banker 💼 | Runner 🏃 | Whiskey connoisseur 🥃', '1990-08-14', ARRAY['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='], ARRAY['finance', 'running', 'whiskey', 'fitness'], 250, true);

-- Verify the data
SELECT id, name, phone, gender, looking_for, credits FROM users ORDER BY name;
