# KAO Mobile App: Supabase Configuration Guide

This guide will help you set up the Supabase backend for the KAO mobile application.

## 1. Create a Supabase Project

1. Go to [https://supabase.com/](https://supabase.com/) and sign up or log in.
2. Create a new project and note your project URL and anon key.

## 2. Configure Flutter App

1. Open `lib/main.dart` and replace the placeholder values with your actual Supabase credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL', // Replace with your Supabase URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your anon key
  debug: true, // Set to false in production
);
```

## 3. Create Database Tables

1. In your Supabase dashboard, go to the SQL Editor.
2. Copy and paste the SQL commands from `supabase_setup.sql` file.
3. Execute the SQL to create all required tables.

## 4. Set Up Storage Buckets

1. In your Supabase dashboard, go to Storage.
2. Create two buckets:
   - `properties_images` - for property images
   - `properties_videos` - for property videos
3. Set the bucket access policies to allow authenticated users to upload and public read access.

## 5. Set Up Row-Level Security Policies

1. In your Supabase dashboard, go to the Authentication section.
2. Configure the authentication providers you want to use (email, social logins, etc.).
3. Go to the SQL Editor and add appropriate RLS policies:

```sql
-- Example RLS policy for properties table
create policy "Users can read all properties"
  on properties for select
  to authenticated
  using (true);

create policy "Users can insert their own properties"
  on properties for insert
  to authenticated
  with check (auth.uid()::text = user_id);

create policy "Users can update their own properties"
  on properties for update
  to authenticated
  using (auth.uid()::text = user_id);

create policy "Users can delete their own properties"
  on properties for delete
  to authenticated
  using (auth.uid()::text = user_id);
```

## 6. Migration Notes

The app has been migrated from PHP API endpoints to Supabase. The key changes include:

1. **API Service**: The `api_service.dart` has been replaced with `supabase_service.dart`.
2. **Media Storage**: Files are now stored in Supabase storage buckets instead of a custom server.
3. **Authentication**: Uses Supabase Auth instead of custom PHP authentication.
4. **Real-time Data**: You can now subscribe to real-time updates using Supabase's real-time features.

## 7. Testing Your Configuration

1. Run the app in debug mode
2. Test user registration and login
3. Test property creation with image/video upload
4. Test property listing and details viewing

## 8. Common Issues and Troubleshooting

- If you have CORS issues, make sure your Supabase project has the correct origins configured.
- If file uploads fail, check that your storage bucket permissions are correctly set up.
- If queries fail, examine the RLS policies to ensure users have appropriate permissions.

For more help, refer to [Supabase documentation](https://supabase.com/docs).
