-- Restored from uploaded PostgreSQL backup.
-- Only the application public schema is migrated; Supabase internal schemas
-- (auth/storage/realtime/etc.) are intentionally excluded.

DO $$
BEGIN
  CREATE TYPE public.app_role AS ENUM ('admin', 'moderator', 'user');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.categories (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  address text NOT NULL,
  payment_method text NOT NULL,
  total numeric DEFAULT 0 NOT NULL,
  status text DEFAULT 'pending' NOT NULL,
  created_at timestamptz DEFAULT now(),
  items jsonb DEFAULT '[]'::jsonb,
  cash_change text,
  payment_details text,
  is_local boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS public.products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  price numeric DEFAULT 0 NOT NULL,
  image_url text,
  is_available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  is_promo boolean DEFAULT false,
  promo_price numeric
);

CREATE TABLE IF NOT EXISTS public.order_items (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE SET NULL,
  quantity integer NOT NULL,
  price_at_time numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.settings (
  key text PRIMARY KEY,
  value jsonb NOT NULL,
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_roles (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL,
  role public.app_role NOT NULL,
  UNIQUE (user_id, role)
);

-- Supabase RLS/auth policies are not copied because this target is plain PostgreSQL.
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

INSERT INTO public.categories (id, name, slug, order_index, created_at) VALUES
  ('9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Pizzas', 'pizzas', '1', '2026-08-14 17:27:03.080141+00'),
  ('99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Especiales', 'especiales', '2', '2026-08-14 17:27:03.080141+00'),
  ('0daad7c7-abe7-48a1-bee7-9ee1abc26c3a', 'Pre-Prontas', 'pre-prontas', '3', '2026-08-14 17:27:03.080141+00'),
  ('fd8b56a1-ffbe-4962-b2a4-cfb4c7df4167', 'Fainá', 'faina', '6', '2026-08-14 17:27:03.080141+00'),
  ('7ac78542-cc66-4b59-b1ac-b685e250df0c', 'Promos', 'promos', '7', '2026-08-14 17:27:03.080141+00'),
  ('4e95343a-eefe-49d5-87df-ff5e6439be00', 'Bebidas', 'bebidas', '8', '2026-08-14 17:27:03.080141+00'),
  ('740fd569-ce85-49f5-a68d-09dc0c26fc3c', 'Guarniciones', 'porciones', '5', '2026-08-14 17:27:03.080141+00'),
  ('47c2e55f-85b0-4ad5-a9cc-e373621369ab', 'PORCIONES', 'porciones-pizza', '4', '2026-08-14 17:27:03.080141+00')
ON CONFLICT DO NOTHING;

INSERT INTO public.products (id, category_id, name, description, price, image_url, is_available, created_at, is_promo, promo_price) VALUES
  ('297ca7f1-18c8-407d-8fc4-378445cecba2', '4e95343a-eefe-49d5-87df-ff5e6439be00', 'Coca-Cola 2 litros', NULL, '90', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.6014212360424556.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('9518daae-1eed-4083-925c-d9872d6ad755', '740fd569-ce85-49f5-a68d-09dc0c26fc3c', 'Papas fritas', NULL, '200', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.896046715055457.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('ba8113f4-9f8e-4b69-93c3-87161be1a949', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Solo salsa', NULL, '480', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.59400835991648.jpg', 't', '2026-08-14 17:27:03.080141+00', 't', NULL),
  ('c96bbf46-3b0e-46bf-a207-bea48ff64c0e', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Tomate', NULL, '740', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('f6301bf4-4e08-412a-92df-ccf3a4da9cb4', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Anana', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.8080891022783687.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('d48ffef3-c00d-4c62-8e62-e8c6e73395d5', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Cebolla', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.17728380296667556.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('cf5778ee-467c-4c55-bc63-8010ec332ed6', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Choclo', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.22470830079485116.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('42bb279c-e3ae-4dae-adaa-26a185d30bc1', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Jamón', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.797704983593035.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('c2feb23d-df34-4628-98fb-7700ac6c88cd', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Lomito', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.7134488056477852.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('a622c352-135a-4f33-9f4b-785f458a5478', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Salame', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.45207800107584784.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('84fb6017-5ab5-4c69-a373-d33e7359061d', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Panceta', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.3472679280609299.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('0eb29dee-7705-491b-a4fc-1532fd479645', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Calabresa', NULL, '740', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('5afb5e89-46e4-4a32-835f-8f8bef217353', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Longaniza', NULL, '740', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('95c287f3-7403-400a-a05b-f265f261564c', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Cheddar', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.13407781176503875.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('ab17dfc5-3c61-45e6-abbc-f342e43cc24b', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Aceituna', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.9047974958762265.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('902508a9-a38c-435c-bc69-5773aea2f0ed', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Champiñones', NULL, '840', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.06983877532797067.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('514c24e4-8295-4389-a519-ddcd21810b4e', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Atún', NULL, '840', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.6519351096396.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('cb306d86-2a5b-4a19-b751-9d7e31dadb9c', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Hawaiana', NULL, '840', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.08825139632489987.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('313a1f51-432f-4d11-b2b5-003a27b55fb2', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Ajo', NULL, '740', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('1036df94-427c-4016-9f75-30c0630dd884', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Hongos', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('10a04045-40ca-4163-a208-8761376e4f7d', '0daad7c7-abe7-48a1-bee7-9ee1abc26c3a', 'Redonda Muzza', NULL, '280', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.0031471595413039566.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('af76fa9d-7b8c-4b3c-83bc-ece101b569f6', '0daad7c7-abe7-48a1-bee7-9ee1abc26c3a', 'Redonda Con sabor', NULL, '340', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.5496235249205276.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('954f49a6-ab15-4723-a15f-3e71a906ad01', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Roquefort', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('12cd0985-e7d7-478b-8ee1-846623cd27ac', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Panceta + ajo', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('a9b3a2e6-f2e1-4b67-a238-26163cea6ff8', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Panceta + cheddar', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('8c718c32-97b1-45fe-af92-bd8a38c8f211', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Churrasco + albahaca', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('0734fb2b-000a-40de-b980-6da013ac6344', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Margarita o Caprese', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('0bf9db1b-bb7b-4fa9-abc7-a641baca7417', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Hongos + pesto + morrón', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('e6da26cf-2334-4036-a279-7dd7bb38f8aa', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Longaniza + aceituna + palmito', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('7b9de41d-edc2-4326-859b-dcec7e795052', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Napolitana', NULL, '840', 'https://images.unsplash.com/photo-1574071318508-1cdbad80ad38?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('6dc14e81-a368-4dd0-b8f3-b30854220da5', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', 'Portuguesa', NULL, '840', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('4821c52f-24e9-40a8-9bda-b610dd8999b4', '47c2e55f-85b0-4ad5-a9cc-e373621369ab', '1/4 muzza', NULL, '200', 'https://images.unsplash.com/photo-1573821663912-56990549294e?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('2870bf44-d03c-40b0-9044-63da303d5320', '47c2e55f-85b0-4ad5-a9cc-e373621369ab', '1/4 con sabor', NULL, '220', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('3e339fd7-f1c7-4feb-a278-d964c4ad40fa', '47c2e55f-85b0-4ad5-a9cc-e373621369ab', '1/4 c/u combinada', NULL, '250', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('d2bcf0e8-825c-4600-a7d0-9d446e93ea52', 'fd8b56a1-ffbe-4962-b2a4-cfb4c7df4167', 'Con muzza', NULL, '250', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.5723126666989868.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('26d65c43-7aaa-4be8-8894-dd222525ed9b', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Tomate cherry', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.1074346494805164.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('ef7b3840-6a0c-4169-bfe9-cd70c9052a99', '740fd569-ce85-49f5-a68d-09dc0c26fc3c', 'Merluza', NULL, '300', 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('8d288fbe-e486-4806-b2af-a984d3460fcf', '740fd569-ce85-49f5-a68d-09dc0c26fc3c', 'Aros de cebolla', NULL, '220', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.006484312043719909.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('0b6aed5a-002d-498b-98c9-0b1de872ca4b', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Huevo', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.7776808225496015.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('6f0fe90a-5761-42e4-a7ed-8cad7a782a93', 'fd8b56a1-ffbe-4962-b2a4-cfb4c7df4167', 'Con sabor', NULL, '300', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('4ece861f-7691-4840-af5b-0d6584eec758', '7ac78542-cc66-4b59-b1ac-b685e250df0c', '1 METRO DE MUZZA + FRITAS + BEBIDA 2L', NULL, '850', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.20318625490150788.png', 't', '2026-08-14 17:27:03.080141+00', 't', NULL),
  ('ccb6ddfe-c5f3-42af-ab51-248f6c04c2ce', 'fd8b56a1-ffbe-4962-b2a4-cfb4c7df4167', 'Fainá', NULL, '200', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.8914981650436782.png', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('e717d3ff-d11d-469d-a69c-11a85433c517', '4e95343a-eefe-49d5-87df-ff5e6439be00', 'Fanta 2 litros', '', '90', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.9056849430780118.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('4703df05-d15b-4d7e-baeb-67f79bb7290c', '4e95343a-eefe-49d5-87df-ff5e6439be00', 'Guaraná 2 litros', NULL, '90', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.12586837595523248.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('d4ffc450-d95e-4844-a213-98e0bd4b3701', '4e95343a-eefe-49d5-87df-ff5e6439be00', 'Sprite 2 litros', NULL, '90', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.25729340665795186.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('4358a0cf-8811-436e-8a7b-8db508f3e4a1', '740fd569-ce85-49f5-a68d-09dc0c26fc3c', 'Nuggets de pollo', NULL, '250', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.8148445641918621.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('976c9357-ff41-447f-8016-d422e0fc7840', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Pesto casero', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.6070037897517321.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('2a34dd8c-c531-465a-987c-d94decb7f6b0', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Albahaca', NULL, '740', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.0009335608526991335.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('d971bcbf-907c-4e85-abe3-c7ec180f5375', '99ab68dd-b68f-481f-a86d-6d6bc6fcb25b', '4 quesos', NULL, '840', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.691388886761078.jpg', 't', '2026-08-14 17:27:03.080141+00', 'f', NULL),
  ('a7a8f4d0-6d57-482b-a205-0bf3a8ef34a5', '9ea974e1-54bf-4de6-977f-0f942f7869fa', 'Metro de MUZZARELLA ', '', '660', 'https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/product-images/products/0.09632691621171563.png', 't', '2026-08-14 17:27:03.080141+00', 't', NULL)
ON CONFLICT DO NOTHING;

INSERT INTO public.orders (id, customer_name, customer_phone, address, payment_method, total, status, created_at, items, cash_change, payment_details, is_local) VALUES
  ('514f22c1-649a-4945-9638-3691caa37307', 'Cliente Local', '0000', 'Venta en Local', 'cash', '740', 'delivered', '2026-08-17 22:35:32.386239+00', '[{"id": "5afb5e89-46e4-4a32-835f-8f8bef217353", "name": "Longaniza", "price": 740, "quantity": 1}]', NULL, NULL, 't'),
  ('f19c39b7-54bb-4a7b-94e1-f723bbcd0446', 'Jorge Marquez', '093867429', 'Brasil 1502', 'transfer', '890', 'preparing', '2026-08-17 22:54:12.572162+00', '[{"id": "c96bbf46-3b0e-46bf-a207-bea48ff64c0e", "name": "Tomate", "price": 740, "options": [], "quantity": 1}, {"id": "297ca7f1-18c8-407d-8fc4-378445cecba2", "name": "Coca-Cola 2 litros", "price": 90, "options": [], "quantity": 1}]', NULL, 'PREX', 'f')
ON CONFLICT DO NOTHING;

-- order_items: no rows in backup.

INSERT INTO public.settings (key, value, updated_at) VALUES
  ('payment_settings', '{"shipping_price": 60, "transfer_options": [{"id": "bank_1", "bank_name": "PREX", "account_holder": "Yoseline Almeida", "account_number": "1157537"}]}', '2026-08-16 14:04:03.99+00'),
  ('social_links', '{"phone": "59898913119", "facebook": "https://www.facebook.com/p/Gonza-Pizzas-100064027603677", "whatsapp": "59898913119", "instagram": "https://www.instagram.com/gonza.pizzas"}', '2026-08-14 20:07:09.12+00'),
  ('alert_settings', '{"enabled": true, "reminder_sound": "bell", "interval_minutes": 2}', '2026-08-16 14:45:45.418+00'),
  ('hero_settings', '{"title": "🍕 Las mejores pizzas directo a tu puerta 🍕", "image_url": "https://qfqfdwhfodfafexyfvhg.supabase.co/storage/v1/object/public/hero-images/hero/1786917698814-w7wiafhxxc.jpg"}', '2026-08-16 22:50:15.383+00')
ON CONFLICT DO NOTHING;

INSERT INTO public.user_roles (id, user_id, role) VALUES
  ('54b5e135-3290-4f8e-a855-d31e99ac3dd6', '704147a8-2c29-47bc-983d-9183592aedb9', 'admin')
ON CONFLICT DO NOTHING;
