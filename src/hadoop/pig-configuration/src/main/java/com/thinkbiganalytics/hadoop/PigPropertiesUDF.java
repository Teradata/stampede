/*------------------------------------------------------------------------------
 * Copyright (c) 2011-2013, Think Big Analytics, Inc. All Rights Reserved.
 *------------------------------------------------------------------------------ */

package com.thinkbiganalytics.hadoop;

import java.util.ArrayList;
import java.util.List;
import java.util.Enumeration;
import java.util.Properties;

import org.apache.pig.EvalFunc;
import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.schema.Schema;
import org.apache.pig.impl.util.UDFContext;


/**
 * Pig UDF wrapper for all the configuratino properties.
 */
public class PigPropertiesUDF extends EvalFunc<DataBag> {

    private TupleFactory tupleFactory = TupleFactory.getInstance();

    @Override
    public DataBag exec(Tuple ignore) throws ExecException {
        DataBag    bag     = BagFactory.getInstance().newDefaultBag();
        UDFContext context = UDFContext.getUDFContext();

        Properties     udfProps     = context.getUDFProperties(this.getClass());;
        Enumeration<?> udfPropsEnum = udfProps.propertyNames();
        while (udfPropsEnum.hasMoreElements()) {
            String name  = (String) udfPropsEnum.nextElement();
            String value = (String) udfProps.getProperty(name);
            Tuple t = tupleFactory.newTuple(2);
            t.set(0, name);
            t.set(1, value);
            bag.add(t);
            log.debug("New UDF Property: "+name+"="+value);
        } 

        Properties     clientProps     = context.getClientSystemProps();
        Enumeration<?> clientPropsEnum = clientProps.propertyNames();
        while (clientPropsEnum.hasMoreElements()) { 
            String name  = (String) clientPropsEnum.nextElement();
            String value = (String) clientProps.getProperty(name);
            Tuple t = tupleFactory.newTuple(2);
            t.set(0, name);
            t.set(1, value);
            bag.add(t);
            log.debug("New Client Property: "+name+"="+value);
        }
        return bag;
    }
    
    @Override
    public void finish() {}

    @Override
    public Schema outputSchema(Schema input) {
        return input;
    }
}
