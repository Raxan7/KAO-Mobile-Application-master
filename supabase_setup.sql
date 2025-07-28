-- Enable pgcrypto for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Properties
CREATE TABLE public.properties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  price numeric NOT NULL,
  property_size text NOT NULL,
  number_of_rooms text NOT NULL,
  status text NOT NULL,
  location text NOT NULL,
  featured text NOT NULL DEFAULT '0'
);

-- Property Media
CREATE TABLE public.property_media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  property_id uuid NOT NULL,
  media_url text NOT NULL,
  media_type text NOT NULL,
  is_thumbnail boolean NOT NULL DEFAULT false
);

ALTER TABLE public.property_media
  ADD CONSTRAINT property_media_property_id_fkey
  FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;

-- Hotels
CREATE TABLE public.hotels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text NOT NULL,
  location text NOT NULL,
  price numeric NOT NULL,
  rating numeric NOT NULL DEFAULT 0,
  image_url text,
  description text
);

-- Motels
CREATE TABLE public.motels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text NOT NULL,
  location text NOT NULL,
  price numeric NOT NULL,
  rating numeric NOT NULL DEFAULT 0,
  image_url text,
  description text
);

-- Spaces
CREATE TABLE public.spaces (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text NOT NULL,
  location text NOT NULL,
  description text,
  price numeric NOT NULL,
  user_id uuid NOT NULL,
  image_url text,
  category_id uuid
);

-- Analytics
CREATE TABLE analytics (
  analytics_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id uuid,
  user_id uuid,
  views_count int DEFAULT 0,
  inquiries_count int DEFAULT 0,
  conversion_rate numeric(5,2) DEFAULT 0.00,
  average_time_on_page numeric(5,2) DEFAULT 0.00,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Appointments
CREATE TABLE appointments (
  appointment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id uuid,
  user_id uuid,
  client_id uuid,
  appointment_date timestamptz NOT NULL,
  status text DEFAULT 'Pending',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Booking Details
CREATE TABLE booking_details (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL,
  room_name text NOT NULL,
  price numeric NOT NULL,
  total_pay numeric NOT NULL DEFAULT 0,
  room_no text,
  user_name text NOT NULL,
  phonenum text NOT NULL,
  address text NOT NULL
);

-- Booking Order
CREATE TABLE booking_order (
  booking_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  room_id uuid NOT NULL,
  check_in date NOT NULL,
  check_out date NOT NULL,
  arrival int NOT NULL DEFAULT 0,
  refund int,
  booking_status text DEFAULT 'pending',
  order_id text,
  trans_id text,
  trans_amt numeric,
  trans_status text,
  trans_resp_msg text,
  rate_review int,
  datentime timestamptz NOT NULL DEFAULT now(),
  status text DEFAULT 'Pending'
);

-- Bookmarks
CREATE TABLE bookmarks (
  bookmark_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  property_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Business Profiles
CREATE TABLE business_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  business_name text,
  business_email text,
  business_phone text,
  industry_category text,
  business_location text,
  company_logo text,
  company_description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Carousel
CREATE TABLE carousel (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image text NOT NULL
);

-- Contact Details
CREATE TABLE contact_details (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  address text NOT NULL,
  gmap text NOT NULL,
  pn1 text NOT NULL,
  pn2 text NOT NULL,
  email text NOT NULL,
  fb text NOT NULL,
  insta text NOT NULL,
  tw text NOT NULL,
  iframe text NOT NULL
);

-- Facilities
CREATE TABLE facilities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  icon text NOT NULL,
  name text NOT NULL,
  description text NOT NULL
);

-- Features
CREATE TABLE features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL
);

-- Hostels
CREATE TABLE hostels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  location text NOT NULL,
  description text NOT NULL,
  business_registration_number text,
  business_licence_number text,
  emergency_contact_number text,
  email text,
  number_of_rooms int,
  number_of_beds int,
  owner_manager_contact text,
  hostel_approved boolean NOT NULL DEFAULT false,
  owner_id uuid NOT NULL
);

-- Hostel Documents
CREATE TABLE hostel_documents (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_id uuid NOT NULL,
  type_of_document text,
  document text,
  document_pdf boolean NOT NULL DEFAULT false
);

-- Hostel Images
CREATE TABLE hostel_images (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_id uuid NOT NULL,
  image text NOT NULL,
  thumb boolean NOT NULL DEFAULT false
);

-- Hostel Services
CREATE TABLE hostel_services (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostel_id uuid NOT NULL,
  service text NOT NULL
);

-- Informative Posts
CREATE TABLE informative_posts (
  post_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  featured boolean DEFAULT false,
  status text DEFAULT 'Draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Informative Post Media
CREATE TABLE informative_post_media (
  media_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL,
  media_url text NOT NULL,
  media_type text NOT NULL,
  thumb boolean DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Likes
CREATE TABLE likes (
  like_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  property_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Lodges
CREATE TABLE lodges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  location text NOT NULL,
  description text NOT NULL,
  business_registration_number text,
  business_licence_number text,
  emergency_contact_number text,
  email text,
  number_of_rooms int,
  number_of_beds int,
  owner_manager_contact text,
  lodge_approved boolean NOT NULL DEFAULT false,
  owner_id uuid NOT NULL
);

-- Lodge Documents
CREATE TABLE lodge_documents (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lodge_id uuid NOT NULL,
  type_of_document text,
  document text,
  document_pdf boolean NOT NULL DEFAULT false
);

-- Lodge Images
CREATE TABLE lodge_images (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lodge_id uuid NOT NULL,
  image text NOT NULL,
  thumb boolean NOT NULL DEFAULT false
);

-- Lodge Services
CREATE TABLE lodge_services (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lodge_id uuid NOT NULL,
  service text NOT NULL
);

-- Messages
CREATE TABLE messages (
  message_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid,
  receiver_id uuid,
  property_id uuid,
  message text,
  created_at timestamptz NOT NULL DEFAULT now(),
  replied boolean DEFAULT false,
  message_type text DEFAULT 'text',
  attachment_url text
);

-- Notifications
CREATE TABLE notifications (
  notification_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id uuid,
  user_id uuid,
  target_user_id uuid,
  message text NOT NULL,
  status text DEFAULT 'Unread',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Offers
CREATE TABLE offers (
  offer_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id uuid,
  user_id uuid,
  broker_id uuid,
  offer_price numeric(15,2) NOT NULL,
  status text DEFAULT 'Pending',
  offer_date timestamptz NOT NULL DEFAULT now()
);

-- Payments
CREATE TABLE payments (
  payment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  amount numeric(15,2) NOT NULL,
  service_type text,
  payment_status text DEFAULT 'Pending',
  payment_date timestamptz NOT NULL DEFAULT now()
);

-- Rating Review
CREATE TABLE rating_review (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL,
  room_id uuid NOT NULL,
  user_id uuid NOT NULL,
  rating int NOT NULL,
  review text NOT NULL,
  seen boolean DEFAULT false,
  datentime timestamptz NOT NULL DEFAULT now()
);

-- Reactions
CREATE TABLE reactions (
  reaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid,
  user_id uuid,
  reaction_type text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Regions
CREATE TABLE regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  region_name text NOT NULL
);

-- Restaurants
CREATE TABLE restaurants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  location text NOT NULL,
  description text NOT NULL,
  business_registration_number text,
  business_licence_number text,
  emergency_contact_number text,
  email text,
  number_of_seats int,
  owner_manager_contact text,
  restaurant_approved boolean NOT NULL DEFAULT false,
  owner_id uuid NOT NULL
);

-- Restaurant Documents
CREATE TABLE restaurant_documents (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  type_of_document text,
  document text,
  document_pdf boolean NOT NULL DEFAULT false
);

-- Restaurant Images
CREATE TABLE restaurant_images (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  image text NOT NULL,
  thumb boolean NOT NULL DEFAULT false
);

-- Restaurant Services
CREATE TABLE restaurant_services (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  service text NOT NULL
);

-- Rooms
CREATE TABLE rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  area int NOT NULL,
  price numeric NOT NULL,
  quantity int NOT NULL,
  adult int NOT NULL,
  children int NOT NULL,
  description text NOT NULL,
  status boolean NOT NULL DEFAULT true,
  removed boolean NOT NULL DEFAULT false,
  hotel_id uuid,
  location text NOT NULL,
  motel_id uuid,
  hostel_id uuid,
  lodge_id uuid
);

-- Room Facilities
CREATE TABLE room_facilities (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  facilities_id uuid NOT NULL
);

-- Room Features
CREATE TABLE room_features (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  features_id uuid NOT NULL
);

-- Room Images
CREATE TABLE room_images (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  image text NOT NULL,
  thumb boolean NOT NULL DEFAULT false
);

-- Services Provided
CREATE TABLE services_provided (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hotel_id uuid NOT NULL,
  service text NOT NULL
);

-- Settings
CREATE TABLE settings (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_title text NOT NULL,
  site_about text NOT NULL,
  shutdown boolean NOT NULL
);

-- Shares
CREATE TABLE shares (
  share_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  property_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Space Categories
CREATE TABLE space_categories (
  category_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Space Media
CREATE TABLE space_media (
  media_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  space_id uuid NOT NULL,
  media_url text NOT NULL,
  media_type text NOT NULL,
  thumb boolean DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Space Subcategories
CREATE TABLE space_subcategories (
  subcategory_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Subscriptions
CREATE TABLE subscriptions (
  subscription_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  plan_type text DEFAULT 'Basic',
  start_date date NOT NULL,
  end_date date NOT NULL,
  status text DEFAULT 'Active',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Team Details
CREATE TABLE team_details (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  picture text NOT NULL
);

-- User Credentials
CREATE TABLE user_cred (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  address text,
  phonenum text,
  pincode int,
  dob date,
  profile text,
  password text,
  is_verified boolean NOT NULL DEFAULT false,
  token text,
  t_expire date,
  status boolean NOT NULL DEFAULT true,
  role text DEFAULT 'user',
  worker_approved boolean NOT NULL DEFAULT false,
  datentime timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  hotel_id uuid,
  agency_name text,
  position text,
  experience_years int,
  bio text,
  license_number text,
  certifications json,
  specializations json,
  skills json,
  portfolio text,
  testimonials json,
  awards text,
  languages text,
  availability text,
  profile_picture text,
  phone text
);

ALTER TABLE public.properties
  ADD CONSTRAINT fk_properties_user
  FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;

ALTER TABLE public.analytics
  ADD CONSTRAINT fk_analytics_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
-- Add foreign key constraints for all property_id fields referencing properties(id)
ALTER TABLE public.analytics
  ADD CONSTRAINT fk_analytics_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.appointments
  ADD CONSTRAINT fk_appointments_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.appointments
  ADD CONSTRAINT fk_appointments_client FOREIGN KEY (client_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.appointments
  ADD CONSTRAINT fk_appointments_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.bookmarks
  ADD CONSTRAINT fk_bookmarks_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.bookmarks
  ADD CONSTRAINT fk_bookmarks_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.business_profiles
  ADD CONSTRAINT fk_business_profiles_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.hostels
  ADD CONSTRAINT fk_hostels_owner FOREIGN KEY (owner_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.informative_posts
  ADD CONSTRAINT fk_informative_posts_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.likes
  ADD CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.likes
  ADD CONSTRAINT fk_likes_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.lodges
  ADD CONSTRAINT fk_lodges_owner FOREIGN KEY (owner_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.notifications
  ADD CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.notifications
  ADD CONSTRAINT fk_notifications_target FOREIGN KEY (target_user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.notifications
  ADD CONSTRAINT fk_notifications_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.offers
  ADD CONSTRAINT fk_offers_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.offers
  ADD CONSTRAINT fk_offers_broker FOREIGN KEY (broker_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.offers
  ADD CONSTRAINT fk_offers_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.payments
  ADD CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.restaurants
  ADD CONSTRAINT fk_restaurants_owner FOREIGN KEY (owner_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.shares
  ADD CONSTRAINT fk_shares_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.shares
  ADD CONSTRAINT fk_shares_property FOREIGN KEY (property_id) REFERENCES public.properties(id) ON DELETE CASCADE;
ALTER TABLE public.spaces
  ADD CONSTRAINT fk_spaces_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;
ALTER TABLE public.subscriptions
  ADD CONSTRAINT fk_subscriptions_user FOREIGN KEY (user_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;

-- User Queries
CREATE TABLE user_queries (
  sr_no uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  subject text NOT NULL,
  message text NOT NULL,
  datentime timestamptz NOT NULL DEFAULT now(),
  seen boolean NOT NULL DEFAULT false
);


-- Add foreign key constraints for all room_id fields referencing rooms(id)
ALTER TABLE public.booking_order
  ADD CONSTRAINT fk_booking_order_room FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;
ALTER TABLE public.rating_review
  ADD CONSTRAINT fk_rating_review_room FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;
ALTER TABLE public.room_facilities
  ADD CONSTRAINT fk_room_facilities_room FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;
ALTER TABLE public.room_features
  ADD CONSTRAINT fk_room_features_room FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;
ALTER TABLE public.room_images
  ADD CONSTRAINT fk_room_images_room FOREIGN KEY (room_id) REFERENCES public.rooms(id) ON DELETE CASCADE;

-- Add foreign key constraints for all client_id fields referencing user_cred(id)
ALTER TABLE public.appointments
  ADD CONSTRAINT fk_appointments_client_id FOREIGN KEY (client_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;

-- Add foreign key constraints for all booking_id fields referencing booking_order(booking_id)
ALTER TABLE public.booking_details
  ADD CONSTRAINT fk_booking_details_booking FOREIGN KEY (booking_id) REFERENCES public.booking_order(booking_id) ON DELETE CASCADE;
ALTER TABLE public.rating_review
  ADD CONSTRAINT fk_rating_review_booking FOREIGN KEY (booking_id) REFERENCES public.booking_order(booking_id) ON DELETE CASCADE;

-- Add foreign key constraints for all hostel_id fields referencing hostels(id)
ALTER TABLE public.hostel_documents
  ADD CONSTRAINT fk_hostel_documents_hostel FOREIGN KEY (hostel_id) REFERENCES public.hostels(id) ON DELETE CASCADE;
ALTER TABLE public.hostel_images
  ADD CONSTRAINT fk_hostel_images_hostel FOREIGN KEY (hostel_id) REFERENCES public.hostels(id) ON DELETE CASCADE;
ALTER TABLE public.hostel_services
  ADD CONSTRAINT fk_hostel_services_hostel FOREIGN KEY (hostel_id) REFERENCES public.hostels(id) ON DELETE CASCADE;

-- Add foreign key constraints for all post_id fields referencing informative_posts(post_id)
ALTER TABLE public.informative_post_media
  ADD CONSTRAINT fk_informative_post_media_post FOREIGN KEY (post_id) REFERENCES public.informative_posts(post_id) ON DELETE CASCADE;

-- Add foreign key constraints for all lodge_id fields referencing lodges(id)
ALTER TABLE public.lodge_documents
  ADD CONSTRAINT fk_lodge_documents_lodge FOREIGN KEY (lodge_id) REFERENCES public.lodges(id) ON DELETE CASCADE;
ALTER TABLE public.lodge_images
  ADD CONSTRAINT fk_lodge_images_lodge FOREIGN KEY (lodge_id) REFERENCES public.lodges(id) ON DELETE CASCADE;
ALTER TABLE public.lodge_services
  ADD CONSTRAINT fk_lodge_services_lodge FOREIGN KEY (lodge_id) REFERENCES public.lodges(id) ON DELETE CASCADE;

-- Add foreign key constraints for all sender_id fields referencing user_cred(id)
ALTER TABLE public.messages
  ADD CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;

-- Add foreign key constraints for all receiver_id fields referencing user_cred(id)
ALTER TABLE public.messages
  ADD CONSTRAINT fk_messages_receiver FOREIGN KEY (receiver_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;

-- Add foreign key constraints for all broker_id fields referencing user_cred(id)
ALTER TABLE public.offers
  ADD CONSTRAINT fk_offers_broker_id FOREIGN KEY (broker_id) REFERENCES public.user_cred(id) ON DELETE CASCADE;

-- Add foreign key constraints for all message_id fields referencing messages(message_id)
ALTER TABLE public.reactions
  ADD CONSTRAINT fk_reactions_message FOREIGN KEY (message_id) REFERENCES public.messages(message_id) ON DELETE CASCADE;

-- Add foreign key constraints for all restaurant_id fields referencing restaurants(id)
ALTER TABLE public.restaurant_documents
  ADD CONSTRAINT fk_restaurant_documents_restaurant FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE CASCADE;
ALTER TABLE public.restaurant_images
  ADD CONSTRAINT fk_restaurant_images_restaurant FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE CASCADE;
ALTER TABLE public.restaurant_services
  ADD CONSTRAINT fk_restaurant_services_restaurant FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE CASCADE;

-- Add foreign key constraints for all hotel_id fields referencing hotels(id)
ALTER TABLE public.services_provided
  ADD CONSTRAINT fk_services_provided_hotel FOREIGN KEY (hotel_id) REFERENCES public.hotels(id) ON DELETE CASCADE;
ALTER TABLE public.user_cred
  ADD CONSTRAINT fk_user_cred_hotel FOREIGN KEY (hotel_id) REFERENCES public.hotels(id) ON DELETE CASCADE;

-- Add foreign key constraints for all space_id fields referencing spaces(id)
ALTER TABLE public.space_media
  ADD CONSTRAINT fk_space_media_space FOREIGN KEY (space_id) REFERENCES public.spaces(id) ON DELETE CASCADE;

-- Add foreign key constraints for all category_id fields referencing space_categories(category_id)
ALTER TABLE public.spaces
  ADD CONSTRAINT fk_spaces_category FOREIGN KEY (category_id) REFERENCES public.space_categories(category_id) ON DELETE CASCADE;
ALTER TABLE public.space_subcategories
  ADD CONSTRAINT fk_space_subcategories_category FOREIGN KEY (category_id) REFERENCES public.space_categories(category_id) ON DELETE CASCADE;