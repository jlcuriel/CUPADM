CREATE OR REPLACE PACKAGE CUPADM.PKG_CUP_SP_CALCULO_CUP is
/******************************************************************************
-----------------------------------------------------------------------------
-- Creación: FEBRERO 23
-- Autor: JLCR
-- Descripción: ACTUALIZA, ESTATUS_CUP Y ESTATUS_FORMATO_SF DE ACURDO A LAS VIGENCIAS DE SUS EVALUACIONES
-- Modificación: Se Actualizo la logica conforme el diagram enviado por Arturo Dúran el Día 05/04/2023
--              documento de WORD CC_RNPSP_CUP_HomEvalu_V3.20.0 - V2.docx
-- Modificacion: 12 JULIO 23, se adiciono la funcion de FN_CALCULA_FECHAS, por modularidad
-- Modificación: 11 Diciembre 2023, conforme observaciones enviadas por El área de Analisis (Arturo Duran)
-----------------------------------------------------------------------------*/

--REGCR_VERIFICA_SF SYS_REFCURSOR;

 FUNCTION FN_ACTUALIZA_ESTATUS_CUP(VPIDEMISION NUMBER) RETURN NUMBER;
 
 FUNCTION FN_ACTUALIZA_SF(VPIDEMISION INT) RETURN NUMBER;
 
 FUNCTION FN_ACTUALIZA_EMISIONSF(VPIDEMISION INT) RETURN NUMBER;
 
 FUNCTION FN_ACTUALIZA_CUP_FUE(VPIDEMISION INT) RETURN NUMBER;
 
 FUNCTION FN_CALCULA_FECHAS(VANIOS INT, VMESES INT, VDIAS INT) RETURN NUMBER;
 
 PROCEDURE CUP_SP_CALCULO_CUP;
 
END PKG_CUP_SP_CALCULO_CUP;

CREATE OR REPLACE PACKAGE BODY CUPADM.PKG_CUP_SP_CALCULO_CUP
AS

    FUNCTION FN_ACTUALIZA_ESTATUS_CUP(VPIDEMISION NUMBER) RETURN NUMBER
    IS
    /******************************************************************************
     NAME: FN_ACTUALIZA_ESTATUS_CUP
     PURPOSE: funcion para actualizar el campo ESTATUS_CUP, en 0 = NO VIGENTE.

     REVISIONS:
     Ver Date Author Description
     --------- ---------- --------------- ------------------------------------
     1.0 26/12/2023 JLCR 1. Creación de la funcion
     
    ******************************************************************************/
    BEGIN

        UPDATE EMISION_SF
             SET ESTATUS_CUP = 0
           WHERE ID_EMISION_SF = VPIDEMISION;

        RETURN 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND  THEN 
            RETURN 0;
        WHEN OTHERS   THEN 
            RETURN 0;

    END FN_ACTUALIZA_ESTATUS_CUP;

    FUNCTION FN_ACTUALIZA_SF(VPIDEMISION INT) RETURN NUMBER
    IS
    /******************************************************************************
     NAME: FN_ACTUALIZA_SF
     PURPOSE: funcion para actualizar el campo ESTATUS_FORMATO_SF, en 0 = NO VIGENTE.

     REVISIONS:
     Ver Date Author Description
     --------- ---------- --------------- ------------------------------------
     1.0 26/12/2023 JLCR 1. Creación de la funcion
     
    ******************************************************************************/
    BEGIN
        UPDATE EMISION_SF
            SET ESTATUS_FORMATO_SF = 0
           WHERE ID_EMISION_SF = VPIDEMISION;

        RETURN 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND  THEN 
            RETURN 0;
        WHEN OTHERS   THEN 
            RETURN 0;

    END FN_ACTUALIZA_SF;

    FUNCTION FN_ACTUALIZA_EMISIONSF(VPIDEMISION INT) RETURN NUMBER
    IS
    /******************************************************************************
     NAME: FN_ACTUALIZA_EMISIONSF
     PURPOSE: funcion para actualizar el campo ESTATUS_FORMATO_SF, en 1= Vigente y ESTATUS_CUP a 0 = NO VIGENTE.

     REVISIONS:
     Ver Date Author Description
     --------- ---------- --------------- ------------------------------------
     1.0 26/12/2023 JLCR 1. Creación de la funcion
     
    ******************************************************************************/
    BEGIN
        UPDATE EMISION_SF
             SET ESTATUS_FORMATO_SF = 1
                , ESTATUS_CUP = 0
         WHERE ID_EMISION_SF = VPIDEMISION;

        RETURN 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND  THEN 
            RETURN 0;
        WHEN OTHERS   THEN 
            RETURN 0;

    END FN_ACTUALIZA_EMISIONSF;
    
    FUNCTION FN_ACTUALIZA_CUP_FUE(VPIDEMISION INT) RETURN NUMBER
    IS
    /******************************************************************************
     NAME: FN_ACTUALIZA_CUP_FUE
     PURPOSE: funcion para actualizar el campo ESTATUS_FORMATO_SF, en 0 = NO VIGENTE y ESTATUS_CUP a 1 = VIGENTE.

     REVISIONS:
     Ver Date Author Description
     --------- ---------- --------------- ------------------------------------
     1.0 26/12/2023 JLCR 1. Creación de la funcion
     
    ******************************************************************************/
    BEGIN
        UPDATE EMISION_SF
             SET ESTATUS_FORMATO_SF = 0
                , ESTATUS_CUP = 1
         WHERE ID_EMISION_SF = VPIDEMISION;

        RETURN 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND  THEN 
            RETURN 0;
        WHEN OTHERS   THEN 
            RETURN 0;

    END FN_ACTUALIZA_CUP_FUE;

    FUNCTION FN_CALCULA_FECHAS(VANIOS INT, VMESES INT, VDIAS INT) RETURN NUMBER
        IS
        /******************************************************************************
     NAME: FN_CALCULA_FECHAS
     PURPOSE: funcion el calculo de fechas a meses y dias.

     REVISIONS:
     Ver Date Author Description
     --------- ---------- --------------- ------------------------------------
     1.0 26/12/2023 JLCR 1. Creación de la funcion
     
    ******************************************************************************/
        BEGIN

            RETURN (VANIOS * 12) + VMESES + (VDIAS / 100);

        EXCEPTION 
            WHEN OTHERS   THEN 
                RETURN 0;
    END FN_CALCULA_FECHAS;

    PROCEDURE CUP_SP_CALCULO_CUP
    IS
        
    CURSOR cr_verifica_sf IS
    SELECT ID_EMISION_SF
          , SF.ID_FORMACION
          , ED.ID_EVALUACION_DESEMPENIO
          , SF.ID_COMPETENCIA_BASICA
          , PER.CUIP
          , SF.ID_PERSONA
          , SF.EMISION_CUP
          , SF.ESTATUS_FORMATO_SF
          , SF.ESTATUS_CUP
          , SF.FECHA_EMISION_SF
          , SF.ID_ECCC
          , EV."Fecha_Evaluacion" FECHA_EVALUACION_ECCC
          , TRUNC ( MONTHS_BETWEEN ( SYSDATE, TRUNC( EV."Fecha_Evaluacion" )) / 12 ) ANIOS_EMISION_ECCC
          , TRUNC(MOD ( FLOOR ( MONTHS_BETWEEN ( SYSDATE, TRUNC ( EV."Fecha_Evaluacion" ) ) ), 12 )) MESES_EMISION_ECCC
          , TRUNC(SYSDATE - add_months(EV."Fecha_Evaluacion", trunc(months_between(SYSDATE, TRUNC ( EV."Fecha_Evaluacion" ))))) DIAS_EMISION_ECCC
          , EV."Fecha_Evaluacion" + 1095 FECHA_VENCIMIENTO_ECCC --1095 DIAS = 3 AÑOS
          , EV."Id_Tipo_Evaluacion" ID_TIPO_EVALUACION
          , EV."borrado" BORRADO
          , EV."Id_Resultado_Integral" ID_RESULTADO_INTEGRAL
          , FI.FECHA_CONCLUSION FECHA_CONCLUSION_FI
          , FI.ESTATUS_CURSO ESTATUS_CURSO_FI
          , CB.FECHA_EVALUACION
          , TRUNC ( MONTHS_BETWEEN ( SYSDATE, TRUNC( CB.FECHA_EVALUACION )) / 12 ) ANIOS_EVALUACION_CB
          , TRUNC(MOD ( FLOOR ( MONTHS_BETWEEN ( SYSDATE, TRUNC ( CB.FECHA_EVALUACION ) ) ), 12 )) MESES_EVALUACION_CB
          , TRUNC(SYSDATE - add_months(CB.FECHA_EVALUACION, trunc(months_between(SYSDATE, TRUNC (CB.FECHA_EVALUACION ))))) DIAS_EVALUACION_CB
          , CB.ESTATUS_REGISTRO ESTATUS_COMPETENCIA
          , ED.FECHA_EVALUACION FECHA_EVALUACION_DESEMPENIO
          , TRUNC ( MONTHS_BETWEEN ( SYSDATE, TRUNC( ED.FECHA_EVALUACION )) / 12 ) ANIOS_DESEMPENIO
          , TRUNC(MOD ( FLOOR ( MONTHS_BETWEEN ( SYSDATE, TRUNC ( ED.FECHA_EVALUACION ) ) ), 12 )) MESES_DESEMPENIO
          , TRUNC(SYSDATE - add_months(ED.FECHA_EVALUACION, trunc(months_between(SYSDATE, TRUNC (ED.FECHA_EVALUACION ))))) DIAS_DESEMPENIO
          , SF.FECHA_EMISION_CUP
          , TRUNC ( MONTHS_BETWEEN ( SYSDATE, TRUNC( sf.fecha_emision_cup )) / 12 ) ANIOS_CUP
          , TRUNC(MOD ( FLOOR ( MONTHS_BETWEEN ( SYSDATE, TRUNC ( sf.fecha_emision_cup ) ) ), 12 )) MESES_CUP
          , TRUNC(SYSDATE - add_months(sf.fecha_emision_cup, trunc(months_between(SYSDATE, TRUNC ( sf.fecha_emision_cup ))))) DIAS_CUP          
          , ED.ESTATUS_EVALUACION ESTATUS_DESEMPENIO
          , TRUNC ( MONTHS_BETWEEN ( SYSDATE, TRUNC( sf.fecha_emision_sf )) / 12 ) ANIOS_EMISION
          , TRUNC(MOD ( FLOOR ( MONTHS_BETWEEN ( SYSDATE, TRUNC ( sf.FECHA_EMISION_SF ) ) ), 12 )) MESES_EMISION
          , TRUNC(SYSDATE - add_months(sf.FECHA_EMISION_SF, trunc(months_between(SYSDATE, TRUNC ( sf.FECHA_EMISION_SF ))))) DIAS_EMISION
          , TRUNC ( MONTHS_BETWEEN ( SYSDATE, TRUNC( FI.FECHA_CONCLUSION )) / 12 ) ANIOS_CONCLUSION_FI
          , TRUNC(MOD ( FLOOR ( MONTHS_BETWEEN ( SYSDATE, TRUNC ( FI.FECHA_CONCLUSION ) ) ), 12 )) MESES_CONCLUSION_FI
          , TRUNC(SYSDATE - add_months(FI.FECHA_CONCLUSION, trunc(months_between(SYSDATE, TRUNC ( FI.FECHA_CONCLUSION ))))) DIAS_CONCLUSION_FI
          , (SELECT count(1) FROM cup_bit_calculo_cup BCC WHERE bcc.id_emision_sf = sf.id_emision_sf) CUMPLE
          , SYSDATE FECHA_COMPARA
         FROM emision_sf sf
         INNER JOIN prsnapp.persona per on per.ID_PERSONA = SF.ID_PERSONA
         LEFT JOIN formacion_inicial fi on FI.ID_FORMACION = SF.id_formacion
         LEFT JOIN competencia_basica CB on CB.ID_COMPETENCIA_BASICA = SF.ID_COMPETENCIA_BASICA
         LEFT JOIN evaluacion_desempenio ED on ED.ID_EVALUACION_DESEMPENIO = sf.ID_EVALUACION_DESEMPENIO
         LEFT JOIN evaluacion@SQLDESA EV ON EV."Id_Evaluacion" = SF.ID_ECCC AND EV."Id_Tipo_Evaluacion" IN (1,2)
         WHERE sf.EMISION_CUP IS NOT NULL AND sf.ESTATUS_CUP in (0,1)
         AND PER.CUIP IN (SELECT CUIP FROM CUIP_PBA_240208)--SOLO PARA PRUEBAS
         ORDER BY sf.id_persona, sf.id_emision_sf DESC;

        REGCR_VERIFICA_SF CR_VERIFICA_SF%ROWTYPE;

        VNBANDERA NUMBER(1) := 0;
        
        VNTIEMPO NUMBER(4,2) := 0.0;
        
BEGIN
    OPEN CR_VERIFICA_SF;

    LOOP

FETCH CR_VERIFICA_SF INTO REGCR_VERIFICA_SF;

        EXIT WHEN CR_VERIFICA_SF%NOTFOUND; -- Último registro;
   
    --- Tiempo a calcular 3 años o 5 años
        IF REGCR_VERIFICA_SF.CUMPLE = 0 THEN 
            VNTIEMPO := 36.0;
        ELSE
            VNTIEMPO := 60.0;
        END IF;
DBMS_OUTPUT.PUT_LINE('VNTIEMPO...' || TO_CHAR(VNTIEMPO));
                --verifica ECCC
                IF TRUNC(REGCR_VERIFICA_SF.fecha_vencimiento_ECCC) BETWEEN TO_DATE('18/05/2019','DD/MM/YYYY') AND TO_DATE('17/05/2020','DD/MM/YYYY') THEN 
                    IF FN_CALCULA_FECHAS(REGCR_VERIFICA_SF.ANIOS_EMISION_ECCC, REGCR_VERIFICA_SF.MESES_EMISION_ECCC, REGCR_VERIFICA_SF.DIAS_EMISION_ECCC) > 48.0
                        AND REGCR_VERIFICA_SF.ID_RESULTADO_INTEGRAL = 1 THEN

                        IF REGCR_VERIFICA_SF.ESTATUS_FORMATO_SF = 1 AND REGCR_VERIFICA_SF.ESTATUS_CUP = 0 THEN 

                            VNBANDERA := FN_ACTUALIZA_SF(REGCR_VERIFICA_SF.ID_EMISION_SF);

                        ELSIF REGCR_VERIFICA_SF.ESTATUS_FORMATO_SF = 0 AND REGCR_VERIFICA_SF.ESTATUS_CUP = 1 THEN

                            VNBANDERA := FN_ACTUALIZA_ESTATUS_CUP(REGCR_VERIFICA_SF.ID_EMISION_SF);

                        END IF;

                    END IF;
                ELSIF FN_CALCULA_FECHAS(REGCR_VERIFICA_SF.ANIOS_EMISION_ECCC, REGCR_VERIFICA_SF.MESES_EMISION_ECCC, REGCR_VERIFICA_SF.DIAS_EMISION_ECCC) > 36.0 
                        AND REGCR_VERIFICA_SF.ID_RESULTADO_INTEGRAL = 1 THEN 

                        IF REGCR_VERIFICA_SF.ESTATUS_FORMATO_SF = 1 AND REGCR_VERIFICA_SF.ESTATUS_CUP = 0 THEN 

                           VNBANDERA := FN_ACTUALIZA_SF(REGCR_VERIFICA_SF.ID_EMISION_SF);

                        ELSIF REGCR_VERIFICA_SF.ESTATUS_FORMATO_SF = 0 AND REGCR_VERIFICA_SF.ESTATUS_CUP = 1 THEN

                            VNBANDERA := FN_ACTUALIZA_ESTATUS_CUP(REGCR_VERIFICA_SF.ID_EMISION_SF);

                        END IF;

                END IF; --verifica ECCC

                --Verifica Competencias Basicas
                IF REGCR_VERIFICA_SF.ID_COMPETENCIA_BASICA != 0 THEN --Modicación (2)
                    IF  FN_CALCULA_FECHAS(REGCR_VERIFICA_SF.anios_evaluacion_cb, REGCR_VERIFICA_SF.meses_evaluacion_cb, REGCR_VERIFICA_SF.dias_evaluacion_cb) > VNTIEMPO --36.0 
                        AND VNBANDERA = 0 THEN
                        BEGIN 

                            VNBANDERA := FN_ACTUALIZA_EMISIONSF(REGCR_VERIFICA_SF.ID_EMISION_SF);

                            --DBMS_OUTPUT.PUT_LINE('ACTUALIZA CB EMISION_SF...' || TO_CHAR(REGCR_VERIFICA_SF.ID_EMISION_SF));

                        END;
                    END IF;
                ELSE
                    IF  FN_CALCULA_FECHAS(REGCR_VERIFICA_SF.ANIOS_CONCLUSION_FI, REGCR_VERIFICA_SF.MESES_CONCLUSION_FI, REGCR_VERIFICA_SF.DIAS_CONCLUSION_FI) > 36.0  
                        AND VNBANDERA = 0 THEN
                        BEGIN 

                            VNBANDERA := FN_ACTUALIZA_EMISIONSF(REGCR_VERIFICA_SF.ID_EMISION_SF);

                            --DBMS_OUTPUT.PUT_LINE('ACTUALIZA CB EMISION_SF...' || TO_CHAR(REGCR_VERIFICA_SF.ID_EMISION_SF));

                        END;
                    END IF;
                END IF;

                --Verifica Evaluacion Desempeño
                IF FN_CALCULA_FECHAS(REGCR_VERIFICA_SF.anios_desempenio, REGCR_VERIFICA_SF.meses_desempenio, REGCR_VERIFICA_SF.dias_desempenio) > VNTIEMPO --36.0 
                    AND VNBANDERA = 0 THEN
                    BEGIN 

                        VNBANDERA := FN_ACTUALIZA_EMISIONSF(REGCR_VERIFICA_SF.ID_EMISION_SF);

                        --DBMS_OUTPUT.PUT_LINE('ACTUALIZA ED EMISION_SF...' || TO_CHAR(REGCR_VERIFICA_SF.ID_EMISION_SF));

                    END;
                ELSIF  REGCR_VERIFICA_SF.ESTATUS_CUP = 1 AND REGCR_VERIFICA_SF.CUMPLE = 0 AND VNBANDERA = 0 THEN
                     
                        VNBANDERA := FN_ACTUALIZA_CUP_FUE(REGCR_VERIFICA_SF.ID_EMISION_SF);
                END IF;


 --           END IF; --cup vigente

    --GENERA BITACORA DE MOVIMIENTOS
    IF VNBANDERA = 1 THEN
        DBMS_OUTPUT.PUT_LINE('GRABA BITACORA...' || TO_CHAR(REGCR_VERIFICA_SF.ID_EMISION_SF));

       INSERT INTO CUP_BIT_CALCULO_CUP ( ID_EMISION_SF
        , ID_FORMACION
        , ID_EVALUACION_DESEMPENIO
        , ID_COMPETENCIA_BASICA
        , CUIP
        , ID_PERSONA
        , EMISION_CUP
        , ESTATUS_FORMATO_SF
        , ESTATUS_CUP
        , FECHA_EMISION_SF
        , ID_ECCC
        , FECHA_EVALUACION_ECCC
        , FECHA_VENCIMIENTO_ECCC)
            VALUES(REGCR_VERIFICA_SF.ID_EMISION_SF
            , REGCR_VERIFICA_SF.ID_FORMACION
            , REGCR_VERIFICA_SF.ID_EVALUACION_DESEMPENIO
            , REGCR_VERIFICA_SF.ID_COMPETENCIA_BASICA
            , REGCR_VERIFICA_SF.CUIP
            , REGCR_VERIFICA_SF.ID_PERSONA
            , REGCR_VERIFICA_SF.EMISION_CUP
            , REGCR_VERIFICA_SF.ESTATUS_FORMATO_SF
            , REGCR_VERIFICA_SF.ESTATUS_CUP
            , REGCR_VERIFICA_SF.FECHA_EMISION_SF
            , REGCR_VERIFICA_SF.ID_ECCC
            , REGCR_VERIFICA_SF.FECHA_EVALUACION_ECCC
            , REGCR_VERIFICA_SF.FECHA_VENCIMIENTO_ECCC);

        VNBANDERA := 0;
    END IF;

    COMMIT;

    END LOOP;

    CLOSE CR_VERIFICA_SF;

    EXCEPTION 
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Problema en el Procedimiento CUP_SP_CALCULO_CUP...CUIP: ' || REGCR_VERIFICA_SF.CUIP);

END CUP_SP_CALCULO_CUP;

END PKG_CUP_SP_CALCULO_CUP;