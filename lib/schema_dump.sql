--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event; Type: TABLE; Schema: public; Owner: cuba; Tablespace: 
--

CREATE TABLE event (
    event_id integer NOT NULL,
    date_begin date DEFAULT now() NOT NULL,
    date_end date DEFAULT now() NOT NULL,
    name character varying(300) NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    time_begin time without time zone DEFAULT '00:00:00'::time without time zone NOT NULL,
    time_end time without time zone DEFAULT '24:00:00'::time without time zone NOT NULL,
    max_participants integer DEFAULT 0 NOT NULL,
    visible visibility DEFAULT ('PUBLIC'::character varying)::visibility NOT NULL,
    content_id integer NOT NULL,
    repeat_annual boolean DEFAULT false,
    repeat_weekly integer,
    repeat_monthly integer,
    repeat_monthly_day integer
);


ALTER TABLE public.event OWNER TO cuba;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: cuba
--

CREATE SEQUENCE event_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO cuba;

--
-- PostgreSQL database dump complete
--

