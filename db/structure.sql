SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: age_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.age_groups (
    id bigint NOT NULL,
    name character varying NOT NULL,
    min_age integer NOT NULL,
    max_age integer NOT NULL,
    requires_parental_consent boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: age_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.age_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: age_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.age_groups_id_seq OWNED BY public.age_groups.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: organization_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_memberships (
    id bigint NOT NULL,
    user_id bigint,
    organization_id bigint NOT NULL,
    role character varying DEFAULT 'member'::character varying NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    joined_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    requested_at timestamp(6) without time zone,
    approved_at timestamp(6) without time zone,
    approved_by_id bigint,
    invited_by_id bigint,
    invitation_token character varying,
    verification_method character varying,
    verification_notes text,
    invited_email character varying,
    last_invited_at timestamp(6) without time zone
);


--
-- Name: organization_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_memberships_id_seq OWNED BY public.organization_memberships.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    organization_type character varying NOT NULL,
    registration_number character varying,
    website character varying,
    verified_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: parental_consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parental_consents (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    parent_name character varying NOT NULL,
    parent_email character varying NOT NULL,
    parent_phone character varying,
    consent_given_at timestamp(6) without time zone,
    consent_method character varying,
    verification_token character varying,
    expires_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parental_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parental_consents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parental_consents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parental_consents_id_seq OWNED BY public.parental_consents.id;


--
-- Name: participation_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participation_rules (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    rule_type character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    configuration text,
    active boolean DEFAULT true,
    priority integer DEFAULT 1,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: participation_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.participation_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participation_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.participation_rules_id_seq OWNED BY public.participation_rules.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    category character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id bigint NOT NULL,
    organization_membership_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- Name: rule_violations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_violations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    participation_rule_id bigint NOT NULL,
    violation_type character varying NOT NULL,
    details text,
    resolved boolean DEFAULT false,
    resolved_at timestamp(6) without time zone,
    resolved_by_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rule_violations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rule_violations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rule_violations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rule_violations_id_seq OWNED BY public.rule_violations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    password_digest character varying,
    first_name character varying,
    last_name character varying,
    date_of_birth date,
    phone_number character varying,
    email_verified_at character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    invitation_token character varying,
    invitation_accepted_at timestamp(6) without time zone,
    invited_by_id integer,
    profile_completed boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: age_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age_groups ALTER COLUMN id SET DEFAULT nextval('public.age_groups_id_seq'::regclass);


--
-- Name: organization_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships ALTER COLUMN id SET DEFAULT nextval('public.organization_memberships_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: parental_consents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parental_consents ALTER COLUMN id SET DEFAULT nextval('public.parental_consents_id_seq'::regclass);


--
-- Name: participation_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participation_rules ALTER COLUMN id SET DEFAULT nextval('public.participation_rules_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- Name: rule_violations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_violations ALTER COLUMN id SET DEFAULT nextval('public.rule_violations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: age_groups age_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.age_groups
    ADD CONSTRAINT age_groups_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: organization_memberships organization_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT organization_memberships_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: parental_consents parental_consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parental_consents
    ADD CONSTRAINT parental_consents_pkey PRIMARY KEY (id);


--
-- Name: participation_rules participation_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participation_rules
    ADD CONSTRAINT participation_rules_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: rule_violations rule_violations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_violations
    ADD CONSTRAINT rule_violations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_age_groups_on_min_age_and_max_age; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_age_groups_on_min_age_and_max_age ON public.age_groups USING btree (min_age, max_age);


--
-- Name: index_age_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_age_groups_on_name ON public.age_groups USING btree (name);


--
-- Name: index_organization_memberships_on_approved_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_approved_at ON public.organization_memberships USING btree (approved_at);


--
-- Name: index_organization_memberships_on_approved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_approved_by_id ON public.organization_memberships USING btree (approved_by_id);


--
-- Name: index_organization_memberships_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organization_memberships_on_invitation_token ON public.organization_memberships USING btree (invitation_token);


--
-- Name: index_organization_memberships_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_invited_by_id ON public.organization_memberships USING btree (invited_by_id);


--
-- Name: index_organization_memberships_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_organization_id ON public.organization_memberships USING btree (organization_id);


--
-- Name: index_organization_memberships_on_organization_id_and_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_organization_id_and_role ON public.organization_memberships USING btree (organization_id, role);


--
-- Name: index_organization_memberships_on_requested_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_requested_at ON public.organization_memberships USING btree (requested_at);


--
-- Name: index_organization_memberships_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_status ON public.organization_memberships USING btree (status);


--
-- Name: index_organization_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_user_id ON public.organization_memberships USING btree (user_id);


--
-- Name: index_organization_memberships_on_user_id_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organization_memberships_on_user_id_and_organization_id ON public.organization_memberships USING btree (user_id, organization_id);


--
-- Name: index_organization_memberships_on_verification_method; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organization_memberships_on_verification_method ON public.organization_memberships USING btree (verification_method);


--
-- Name: index_organizations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_name ON public.organizations USING btree (name);


--
-- Name: index_organizations_on_organization_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_organization_type ON public.organizations USING btree (organization_type);


--
-- Name: index_parental_consents_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parental_consents_on_user_id ON public.parental_consents USING btree (user_id);


--
-- Name: index_parental_consents_on_verification_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parental_consents_on_verification_token ON public.parental_consents USING btree (verification_token);


--
-- Name: index_participation_rules_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participation_rules_on_active ON public.participation_rules USING btree (active);


--
-- Name: index_participation_rules_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participation_rules_on_organization_id ON public.participation_rules USING btree (organization_id);


--
-- Name: index_participation_rules_on_organization_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_participation_rules_on_organization_id_and_name ON public.participation_rules USING btree (organization_id, name);


--
-- Name: index_participation_rules_on_organization_id_and_rule_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participation_rules_on_organization_id_and_rule_type ON public.participation_rules USING btree (organization_id, rule_type);


--
-- Name: index_participation_rules_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participation_rules_on_priority ON public.participation_rules USING btree (priority);


--
-- Name: index_permissions_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_category ON public.permissions USING btree (category);


--
-- Name: index_permissions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_name ON public.permissions USING btree (name);


--
-- Name: index_role_permissions_on_membership_and_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_role_permissions_on_membership_and_permission ON public.role_permissions USING btree (organization_membership_id, permission_id);


--
-- Name: index_role_permissions_on_organization_membership_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_permissions_on_organization_membership_id ON public.role_permissions USING btree (organization_membership_id);


--
-- Name: index_role_permissions_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_permissions_on_permission_id ON public.role_permissions USING btree (permission_id);


--
-- Name: index_rule_violations_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_created_at ON public.rule_violations USING btree (created_at);


--
-- Name: index_rule_violations_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_organization_id ON public.rule_violations USING btree (organization_id);


--
-- Name: index_rule_violations_on_participation_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_participation_rule_id ON public.rule_violations USING btree (participation_rule_id);


--
-- Name: index_rule_violations_on_resolved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_resolved ON public.rule_violations USING btree (resolved);


--
-- Name: index_rule_violations_on_resolved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_resolved_by_id ON public.rule_violations USING btree (resolved_by_id);


--
-- Name: index_rule_violations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_user_id ON public.rule_violations USING btree (user_id);


--
-- Name: index_rule_violations_on_user_id_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_user_id_and_organization_id ON public.rule_violations USING btree (user_id, organization_id);


--
-- Name: index_rule_violations_on_violation_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_violations_on_violation_type ON public.rule_violations USING btree (violation_type);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_phone_number ON public.users USING btree (phone_number);


--
-- Name: rule_violations fk_rails_4330ea9854; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_violations
    ADD CONSTRAINT fk_rails_4330ea9854 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: role_permissions fk_rails_439e640a3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_rails_439e640a3f FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: role_permissions fk_rails_444f4b3291; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_rails_444f4b3291 FOREIGN KEY (organization_membership_id) REFERENCES public.organization_memberships(id);


--
-- Name: organization_memberships fk_rails_48b5062060; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT fk_rails_48b5062060 FOREIGN KEY (approved_by_id) REFERENCES public.users(id);


--
-- Name: rule_violations fk_rails_5350bc6d7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_violations
    ADD CONSTRAINT fk_rails_5350bc6d7e FOREIGN KEY (participation_rule_id) REFERENCES public.participation_rules(id);


--
-- Name: organization_memberships fk_rails_57cf70d280; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT fk_rails_57cf70d280 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: organization_memberships fk_rails_715ab7f4fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT fk_rails_715ab7f4fe FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: rule_violations fk_rails_aa6e1ec78e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_violations
    ADD CONSTRAINT fk_rails_aa6e1ec78e FOREIGN KEY (resolved_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_ae14a5013f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ae14a5013f FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- Name: rule_violations fk_rails_ca99ca0fcb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_violations
    ADD CONSTRAINT fk_rails_ca99ca0fcb FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: parental_consents fk_rails_d7540031ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parental_consents
    ADD CONSTRAINT fk_rails_d7540031ec FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: participation_rules fk_rails_f4e4065e2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participation_rules
    ADD CONSTRAINT fk_rails_f4e4065e2e FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: organization_memberships fk_rails_f61ba22770; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_memberships
    ADD CONSTRAINT fk_rails_f61ba22770 FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250711140102'),
('20250711132940'),
('20250711130921'),
('20250711130333'),
('20250711113733'),
('20250711113722'),
('20250711113027'),
('20250711113014'),
('20250711112705'),
('20250710103042'),
('20250710102947'),
('20250710102807'),
('20250710102705'),
('20250710101842');

