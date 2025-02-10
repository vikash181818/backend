const express = require("express");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");
const db = require("../config/firebase"); // Firestore instance
const router = express.Router();




const forgotPassword=async(req,res)=>{
    try{
  const {email} =req.body;
  if(!email){
    return res.status(400).send({message:"Please provide email"})
  }
  const checkUser=await user.findOne({email});
  if(!checkUser){
    return res.status(400).send({message:"User not found please regisetr"})
  }
  const token=jwt.sign({email},process.env.JWT_SECRET,{expiresIn:"1h"});
  const transporter=nodemailer.createTransport({
    service:"gmail",
    secure: true,
    auth: {
      user: "kumarsharmavikash185@gmail.com", // Replace with your email
      pass: "zuym bloq rypx zipq",            // Replace with your email password or app password
    },
  })
  const receiver={
    from :"kumarsharmavikash185@gmail.com",
    to:email,
    subject:"Password reset request",
    text:"Click on this link generate your new password${token}"
    
  }
    }catch(error){
    }
  }