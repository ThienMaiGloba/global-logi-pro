--
-- PostgreSQL database dump
--

\restrict bbrmjluDvMkXfrVabVDdrRgiABiRk3AXncLdBOV1LqgnEz9WeQ0MjK8zEFlGbbV

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AssignmentStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AssignmentStatus" AS ENUM (
    'OFFERED',
    'ACCEPTED',
    'REJECTED',
    'EXPIRED',
    'CANCELLED',
    'COMPLETED'
);


--
-- Name: OrderStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."OrderStatus" AS ENUM (
    'DRAFT',
    'QUOTED',
    'CONFIRMED',
    'SEARCHING_DRIVER',
    'DRIVER_OFFER',
    'DRIVER_ACCEPTED',
    'DRIVER_ARRIVING',
    'ARRIVED_PICKUP',
    'LOADING',
    'IN_TRANSIT',
    'ARRIVED_STOP',
    'DELIVERING',
    'DELIVERED',
    'COMPLETED',
    'CANCELLED'
);


--
-- Name: RoleType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RoleType" AS ENUM (
    'CUSTOMER',
    'DRIVER_BIKE',
    'DRIVER_CAR',
    'DRIVER_TRUCK',
    'FLEET_MANAGER',
    'DISPATCHER',
    'ADMIN',
    'SUPER_ADMIN'
);


--
-- Name: StopType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."StopType" AS ENUM (
    'PICKUP',
    'DELIVERY',
    'WAYPOINT'
);


--
-- Name: VehicleType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."VehicleType" AS ENUM (
    'MOTORBIKE',
    'VAN_500KG',
    'VAN_700KG',
    'TRUCK_500KG',
    'TRUCK_750KG',
    'TRUCK_1T',
    'TRUCK_1_5T',
    'TRUCK_2T',
    'TRUCK_2_5T',
    'TRUCK_3_5T',
    'TRUCK_5T',
    'TRUCK_8T',
    'TRUCK_15T',
    'BUS_16',
    'BUS_52',
    'SLEEPER_BUS',
    'RESCUE',
    'CRANE',
    'LIFTGATE',
    'SEPTIC',
    'CONCRETE',
    'CONTAINER'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AuditLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."AuditLog" (
    id text NOT NULL,
    "actorId" text,
    action text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text,
    payload jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: DriverLocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DriverLocation" (
    id text NOT NULL,
    "driverId" text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    heading double precision,
    accuracy double precision,
    battery integer,
    online boolean DEFAULT true NOT NULL,
    "tripId" text,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: DriverProfile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DriverProfile" (
    id text NOT NULL,
    "userId" text NOT NULL,
    online boolean DEFAULT false NOT NULL,
    "isVerified" boolean DEFAULT false NOT NULL,
    rating double precision DEFAULT 5 NOT NULL,
    "acceptRate" double precision DEFAULT 1 NOT NULL,
    "cancelRate" double precision DEFAULT 0 NOT NULL,
    "responseSeconds" double precision DEFAULT 0 NOT NULL,
    "batteryPercent" integer
);


--
-- Name: Order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Order" (
    id text NOT NULL,
    "customerId" text NOT NULL,
    status public."OrderStatus" DEFAULT 'DRAFT'::public."OrderStatus" NOT NULL,
    price integer DEFAULT 0 NOT NULL,
    currency text DEFAULT 'VND'::text NOT NULL,
    notes text,
    "idempotencyKey" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: OrderAssignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OrderAssignment" (
    id text NOT NULL,
    "orderId" text NOT NULL,
    "driverId" text NOT NULL,
    status public."AssignmentStatus" DEFAULT 'OFFERED'::public."AssignmentStatus" NOT NULL,
    "offeredAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "acceptedAt" timestamp(3) without time zone,
    "lockedAt" timestamp(3) without time zone
);


--
-- Name: OrderStop; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OrderStop" (
    id text NOT NULL,
    "orderId" text NOT NULL,
    sequence integer NOT NULL,
    type public."StopType" NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    address text NOT NULL,
    "arrivedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    phone text NOT NULL,
    email text,
    "passwordHash" text NOT NULL,
    "fullName" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "isVerified" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "driverProfileId" text
);


--
-- Name: UserRole; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserRole" (
    id text NOT NULL,
    "userId" text NOT NULL,
    role public."RoleType" NOT NULL
);


--
-- Name: Vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Vehicle" (
    id text NOT NULL,
    "driverId" text NOT NULL,
    type public."VehicleType" NOT NULL,
    "plateNumber" text NOT NULL,
    "capacityKg" integer NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "driverProfileId" text
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Data for Name: AuditLog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."AuditLog" (id, "actorId", action, "entityType", "entityId", payload, "createdAt") FROM stdin;
\.


--
-- Data for Name: DriverLocation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."DriverLocation" (id, "driverId", latitude, longitude, heading, accuracy, battery, online, "tripId", "updatedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: DriverProfile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."DriverProfile" (id, "userId", online, "isVerified", rating, "acceptRate", "cancelRate", "responseSeconds", "batteryPercent") FROM stdin;
77d9465808dce138569e45243f0248fd	4aee43aa5abaf376f66a936445b07682	t	t	5	1	0	0	\N
\.


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Order" (id, "customerId", status, price, currency, notes, "idempotencyKey", "createdAt", "updatedAt") FROM stdin;
7b9b072e-d6ae-42da-934a-ad33a55fb781	4c1a4d80-6dbe-4416-bd7f-18632f7f2a24	DRAFT	150000	VND	GLOBAL LOGI PRO - REAL ORDER TEST	real-order-test-20260916-02	2026-09-16 07:51:09.414	2026-09-16 07:51:09.414
6da774e3-b098-44b8-ba05-124e8d70f55d	4c1a4d80-6dbe-4416-bd7f-18632f7f2a24	DRAFT	1500000	VND	\N	customer-1789568555357589	2026-09-16 14:22:35.955	2026-09-16 14:22:35.955
aecae40e-e404-4193-a3cc-39fe1a54797e	4c1a4d80-6dbe-4416-bd7f-18632f7f2a24	DRAFT	1500000	VND	xe van 1t	customer-1789568567754008	2026-09-16 14:22:48.213	2026-09-16 14:22:48.213
aa549e24-6dd1-4483-a213-f0b7d94afb3e	4c1a4d80-6dbe-4416-bd7f-18632f7f2a24	DRAFT	1500000	VND	xe van 1t	customer-1789568597064175	2026-09-16 14:23:17.498	2026-09-16 14:23:17.498
\.


--
-- Data for Name: OrderAssignment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OrderAssignment" (id, "orderId", "driverId", status, "offeredAt", "expiresAt", "acceptedAt", "lockedAt") FROM stdin;
\.


--
-- Data for Name: OrderStop; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OrderStop" (id, "orderId", sequence, type, latitude, longitude, address, "arrivedAt", "completedAt") FROM stdin;
27a92e3e-c893-4d1c-960e-43c7399262e6	7b9b072e-d6ae-42da-934a-ad33a55fb781	0	PICKUP	10.7769	106.7009	Điểm lấy hàng - TP.HCM	\N	\N
72f97a12-72b6-4480-874a-5af5ddca4051	7b9b072e-d6ae-42da-934a-ad33a55fb781	1	DELIVERY	10.8231	106.6297	Điểm giao hàng - TP.HCM	\N	\N
c58113a4-a849-4ee1-b53a-6fb92eee4cf9	6da774e3-b098-44b8-ba05-124e8d70f55d	0	PICKUP	10.7727964	106.5737442	202b Hoàng Văn Thụ	\N	\N
de0e82ed-f8a9-46c5-a95c-18622e4c07a0	6da774e3-b098-44b8-ba05-124e8d70f55d	1	DELIVERY	10.7727964	106.5737442	kcn bình minh	\N	\N
7a768338-9f13-432e-8c6a-4e381de82eda	aecae40e-e404-4193-a3cc-39fe1a54797e	0	PICKUP	10.7727964	106.5737442	202b Hoàng Văn Thụ	\N	\N
c00e37b5-75d1-4d4b-8cd2-afeeef0f7cdc	aecae40e-e404-4193-a3cc-39fe1a54797e	1	DELIVERY	10.7727964	106.5737442	kcn bình minh	\N	\N
52a91c54-87ed-435e-b8d1-dca6840268e7	aa549e24-6dd1-4483-a213-f0b7d94afb3e	0	PICKUP	10.7727959	106.5737371	202b Hoàng Văn Thụ	\N	\N
9d49ca5f-fd09-45b1-b095-88713929d187	aa549e24-6dd1-4483-a213-f0b7d94afb3e	1	DELIVERY	10.7727959	106.5737371	kcn bình minh	\N	\N
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, phone, email, "passwordHash", "fullName", "isActive", "isVerified", "createdAt", "updatedAt", "driverProfileId") FROM stdin;
4c1a4d80-6dbe-4416-bd7f-18632f7f2a24	09000027	\N	$2b$12$ROr7UObAqQ8ZMw.B7U6Xc.yp4cMCx7A9vXKrW796vrvWOcszKolaK	Global Logi Pro Test	t	f	2026-09-16 07:32:27.467	2026-09-16 07:32:27.467	\N
6ecab5602e8459192f9b84ab29f8c1e8	09000001	\N	$2b$12$TRRS.uafECzvkO.OgklGxu/Ebj9G3xr.xEsvXrluLd.tF05RwViz6	Global Logi Pro Admin Test	t	t	2026-09-16 15:01:37.341	2026-09-16 15:01:37.341	\N
4aee43aa5abaf376f66a936445b07682	09000002	\N	$2b$12$YE1Zw8n1IfWyzuxG5sRX0.byn6pHo7YrQONtDgKk1fBllAfn31NtC	Global Logi Pro Driver Test	t	t	2026-09-16 15:01:37.341	2026-09-16 15:01:37.341	77d9465808dce138569e45243f0248fd
\.


--
-- Data for Name: UserRole; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserRole" (id, "userId", role) FROM stdin;
0c82702a-ac1a-4ad3-9f77-b262cdd6ebb2	4c1a4d80-6dbe-4416-bd7f-18632f7f2a24	CUSTOMER
02eb21c5399d859afbfdc3e12fb9cd62	6ecab5602e8459192f9b84ab29f8c1e8	ADMIN
d6d96950bc3027f22364e67822c9fff2	4aee43aa5abaf376f66a936445b07682	DRIVER_TRUCK
\.


--
-- Data for Name: Vehicle; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Vehicle" (id, "driverId", type, "plateNumber", "capacityKg", "isActive", "createdAt", "driverProfileId") FROM stdin;
4a39e2cfc69a22b3f4dc815f24a382f5	4aee43aa5abaf376f66a936445b07682	TRUCK_1T	TEST-GLP-001	1000	t	2026-09-16 15:01:37.341	\N
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
6aa090ea-65cb-4a03-a97a-9d6dcf50b663	de833727bf038a16548ec83f09b5b993666e1e1b668753f6a98ea453f7f6f973	2026-09-16 12:14:21.345159+07	00000000000000_baseline	\N	\N	2026-09-16 12:14:21.269329+07	1
\.


--
-- Name: AuditLog AuditLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_pkey" PRIMARY KEY (id);


--
-- Name: DriverLocation DriverLocation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DriverLocation"
    ADD CONSTRAINT "DriverLocation_pkey" PRIMARY KEY (id);


--
-- Name: DriverProfile DriverProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DriverProfile"
    ADD CONSTRAINT "DriverProfile_pkey" PRIMARY KEY (id);


--
-- Name: OrderAssignment OrderAssignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderAssignment"
    ADD CONSTRAINT "OrderAssignment_pkey" PRIMARY KEY (id);


--
-- Name: OrderStop OrderStop_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderStop"
    ADD CONSTRAINT "OrderStop_pkey" PRIMARY KEY (id);


--
-- Name: Order Order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_pkey" PRIMARY KEY (id);


--
-- Name: UserRole UserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Vehicle Vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Vehicle"
    ADD CONSTRAINT "Vehicle_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AuditLog_entityType_entityId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "AuditLog_entityType_entityId_idx" ON public."AuditLog" USING btree ("entityType", "entityId");


--
-- Name: DriverLocation_driverId_updatedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "DriverLocation_driverId_updatedAt_idx" ON public."DriverLocation" USING btree ("driverId", "updatedAt");


--
-- Name: DriverProfile_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "DriverProfile_userId_key" ON public."DriverProfile" USING btree ("userId");


--
-- Name: OrderAssignment_driverId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OrderAssignment_driverId_status_idx" ON public."OrderAssignment" USING btree ("driverId", status);


--
-- Name: OrderAssignment_orderId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OrderAssignment_orderId_status_idx" ON public."OrderAssignment" USING btree ("orderId", status);


--
-- Name: OrderStop_orderId_sequence_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OrderStop_orderId_sequence_key" ON public."OrderStop" USING btree ("orderId", sequence);


--
-- Name: Order_idempotencyKey_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Order_idempotencyKey_key" ON public."Order" USING btree ("idempotencyKey");


--
-- Name: UserRole_userId_role_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserRole_userId_role_key" ON public."UserRole" USING btree ("userId", role);


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_phone_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_phone_key" ON public."User" USING btree (phone);


--
-- Name: Vehicle_plateNumber_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Vehicle_plateNumber_key" ON public."Vehicle" USING btree ("plateNumber");


--
-- Name: AuditLog AuditLog_actorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."AuditLog"
    ADD CONSTRAINT "AuditLog_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: DriverLocation DriverLocation_driverId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."DriverLocation"
    ADD CONSTRAINT "DriverLocation_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES public."DriverProfile"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderAssignment OrderAssignment_driverId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderAssignment"
    ADD CONSTRAINT "OrderAssignment_driverId_fkey" FOREIGN KEY ("driverId") REFERENCES public."DriverProfile"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderAssignment OrderAssignment_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderAssignment"
    ADD CONSTRAINT "OrderAssignment_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."Order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderStop OrderStop_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OrderStop"
    ADD CONSTRAINT "OrderStop_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."Order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order Order_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserRole UserRole_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_driverProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_driverProfileId_fkey" FOREIGN KEY ("driverProfileId") REFERENCES public."DriverProfile"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Vehicle Vehicle_driverProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Vehicle"
    ADD CONSTRAINT "Vehicle_driverProfileId_fkey" FOREIGN KEY ("driverProfileId") REFERENCES public."DriverProfile"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict bbrmjluDvMkXfrVabVDdrRgiABiRk3AXncLdBOV1LqgnEz9WeQ0MjK8zEFlGbbV

