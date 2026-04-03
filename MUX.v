//Example is 256to1MUX_12bit
module LargeMultibitMuX_withE(Imb_255,Imb_254,Imb_253,Imb_252,Imb_251,Imb_250,Imb_249,Imb_248,Imb_247,Imb_246,Imb_245,Imb_244,Imb_243,Imb_242,Imb_241,Imb_240,Imb_239,Imb_238,Imb_237,Imb_236,Imb_235,Imb_234,Imb_233,Imb_232,Imb_231,Imb_230,Imb_229,Imb_228,Imb_227,Imb_226,Imb_225,Imb_224,Imb_223,Imb_222,Imb_221,Imb_220,Imb_219,Imb_218,Imb_217,Imb_216,Imb_215,Imb_214,Imb_213,Imb_212,Imb_211,Imb_210,Imb_209,Imb_208,Imb_207,Imb_206,Imb_205,Imb_204,Imb_203,Imb_202,Imb_201,Imb_200,Imb_199,Imb_198,Imb_197,Imb_196,Imb_195,Imb_194,Imb_193,Imb_192,Imb_191,Imb_190,Imb_189,Imb_188,Imb_187,Imb_186,Imb_185,Imb_184,Imb_183,Imb_182,Imb_181,Imb_180,Imb_179,Imb_178,Imb_177,Imb_176,Imb_175,Imb_174,Imb_173,Imb_172,Imb_171,Imb_170,Imb_169,Imb_168,Imb_167,Imb_166,Imb_165,Imb_164,Imb_163,Imb_162,Imb_161,Imb_160,Imb_159,Imb_158,Imb_157,Imb_156,Imb_155,Imb_154,Imb_153,Imb_152,Imb_151,Imb_150,Imb_149,Imb_148,Imb_147,Imb_146,Imb_145,Imb_144,Imb_143,Imb_142,Imb_141,Imb_140,Imb_139,Imb_138,Imb_137,Imb_136,Imb_135,Imb_134,Imb_133,Imb_132,Imb_131,Imb_130,Imb_129,Imb_128,Imb_127,Imb_126,Imb_125,Imb_124,Imb_123,Imb_122,Imb_121,Imb_120,Imb_119,Imb_118,Imb_117,Imb_116,Imb_115,Imb_114,Imb_113,Imb_112,Imb_111,Imb_110,Imb_109,Imb_108,Imb_107,Imb_106,Imb_105,Imb_104,Imb_103,Imb_102,Imb_101,Imb_100,Imb_99,Imb_98,Imb_97,Imb_96,Imb_95,Imb_94,Imb_93,Imb_92,Imb_91,Imb_90,Imb_89,Imb_88,Imb_87,Imb_86,Imb_85,Imb_84,Imb_83,Imb_82,Imb_81,Imb_80,Imb_79,Imb_78,Imb_77,Imb_76,Imb_75,Imb_74,Imb_73,Imb_72,Imb_71,Imb_70,Imb_69,Imb_68,Imb_67,Imb_66,Imb_65,Imb_64,Imb_63,Imb_62,Imb_61,Imb_60,Imb_59,Imb_58,Imb_57,Imb_56,Imb_55,Imb_54,Imb_53,Imb_52,Imb_51,Imb_50,Imb_49,Imb_48,Imb_47,Imb_46,Imb_45,Imb_44,Imb_43,Imb_42,Imb_41,Imb_40,Imb_39,Imb_38,Imb_37,Imb_36,Imb_35,Imb_34,Imb_33,Imb_32,Imb_31,Imb_30,Imb_29,Imb_28,Imb_27,Imb_26,Imb_25,Imb_24,Imb_23,Imb_22,Imb_21,Imb_20,Imb_19,Imb_18,Imb_17,Imb_16,Imb_15,Imb_14,Imb_13,Imb_12,Imb_11,Imb_10,Imb_9,Imb_8,Imb_7,Imb_6,Imb_5,Imb_4,Imb_3,Imb_2,Imb_1,Imb_0, S, E, Y);
	parameter n = 8; //n
  	parameter twopn = 256;//two_power_n
  	parameter buswidth = 12; //bus-width
  	input [n-1:0] S;
	input E;
  	input [buswidth-1:0] Imb_255,Imb_254,Imb_253,Imb_252,Imb_251,Imb_250,Imb_249,Imb_248,Imb_247,Imb_246,Imb_245,Imb_244,Imb_243,Imb_242,Imb_241,Imb_240,Imb_239,Imb_238,Imb_237,Imb_236,Imb_235,Imb_234,Imb_233,Imb_232,Imb_231,Imb_230,Imb_229,Imb_228,Imb_227,Imb_226,Imb_225,Imb_224,Imb_223,Imb_222,Imb_221,Imb_220,Imb_219,Imb_218,Imb_217,Imb_216,Imb_215,Imb_214,Imb_213,Imb_212,Imb_211,Imb_210,Imb_209,Imb_208,Imb_207,Imb_206,Imb_205,Imb_204,Imb_203,Imb_202,Imb_201,Imb_200,Imb_199,Imb_198,Imb_197,Imb_196,Imb_195,Imb_194,Imb_193,Imb_192,Imb_191,Imb_190,Imb_189,Imb_188,Imb_187,Imb_186,Imb_185,Imb_184,Imb_183,Imb_182,Imb_181,Imb_180,Imb_179,Imb_178,Imb_177,Imb_176,Imb_175,Imb_174,Imb_173,Imb_172,Imb_171,Imb_170,Imb_169,Imb_168,Imb_167,Imb_166,Imb_165,Imb_164,Imb_163,Imb_162,Imb_161,Imb_160,Imb_159,Imb_158,Imb_157,Imb_156,Imb_155,Imb_154,Imb_153,Imb_152,Imb_151,Imb_150,Imb_149,Imb_148,Imb_147,Imb_146,Imb_145,Imb_144,Imb_143,Imb_142,Imb_141,Imb_140,Imb_139,Imb_138,Imb_137,Imb_136,Imb_135,Imb_134,Imb_133,Imb_132,Imb_131,Imb_130,Imb_129,Imb_128,Imb_127,Imb_126,Imb_125,Imb_124,Imb_123,Imb_122,Imb_121,Imb_120,Imb_119,Imb_118,Imb_117,Imb_116,Imb_115,Imb_114,Imb_113,Imb_112,Imb_111,Imb_110,Imb_109,Imb_108,Imb_107,Imb_106,Imb_105,Imb_104,Imb_103,Imb_102,Imb_101,Imb_100,Imb_99,Imb_98,Imb_97,Imb_96,Imb_95,Imb_94,Imb_93,Imb_92,Imb_91,Imb_90,Imb_89,Imb_88,Imb_87,Imb_86,Imb_85,Imb_84,Imb_83,Imb_82,Imb_81,Imb_80,Imb_79,Imb_78,Imb_77,Imb_76,Imb_75,Imb_74,Imb_73,Imb_72,Imb_71,Imb_70,Imb_69,Imb_68,Imb_67,Imb_66,Imb_65,Imb_64,Imb_63,Imb_62,Imb_61,Imb_60,Imb_59,Imb_58,Imb_57,Imb_56,Imb_55,Imb_54,Imb_53,Imb_52,Imb_51,Imb_50,Imb_49,Imb_48,Imb_47,Imb_46,Imb_45,Imb_44,Imb_43,Imb_42,Imb_41,Imb_40,Imb_39,Imb_38,Imb_37,Imb_36,Imb_35,Imb_34,Imb_33,Imb_32,Imb_31,Imb_30,Imb_29,Imb_28,Imb_27,Imb_26,Imb_25,Imb_24,Imb_23,Imb_22,Imb_21,Imb_20,Imb_19,Imb_18,Imb_17,Imb_16,Imb_15,Imb_14,Imb_13,Imb_12,Imb_11,Imb_10,Imb_9,Imb_8,Imb_7,Imb_6,Imb_5,Imb_4,Imb_3,Imb_2,Imb_1,Imb_0;
	output wire [buswidth-1:0] Y;
	
	
	
	generate
    genvar i; // Generate variable for the loop
    for (i = 0; i < (buswidth); i = i + 1) 
        begin
			LargeMuX_withE #(.n(8), .twopn(256)) inst1bMUX({Imb_255[i],Imb_254[i],Imb_253[i],Imb_252[i],Imb_251[i],Imb_250[i],Imb_249[i],Imb_248[i],Imb_247[i],Imb_246[i],Imb_245[i],Imb_244[i],Imb_243[i],Imb_242[i],Imb_241[i],Imb_240[i],Imb_239[i],Imb_238[i],Imb_237[i],Imb_236[i],Imb_235[i],Imb_234[i],Imb_233[i],Imb_232[i],Imb_231[i],Imb_230[i],Imb_229[i],Imb_228[i],Imb_227[i],Imb_226[i],Imb_225[i],Imb_224[i],Imb_223[i],Imb_222[i],Imb_221[i],Imb_220[i],Imb_219[i],Imb_218[i],Imb_217[i],Imb_216[i],Imb_215[i],Imb_214[i],Imb_213[i],Imb_212[i],Imb_211[i],Imb_210[i],Imb_209[i],Imb_208[i],Imb_207[i],Imb_206[i],Imb_205[i],Imb_204[i],Imb_203[i],Imb_202[i],Imb_201[i],Imb_200[i],Imb_199[i],Imb_198[i],Imb_197[i],Imb_196[i],Imb_195[i],Imb_194[i],Imb_193[i],Imb_192[i],Imb_191[i],Imb_190[i],Imb_189[i],Imb_188[i],Imb_187[i],Imb_186[i],Imb_185[i],Imb_184[i],Imb_183[i],Imb_182[i],Imb_181[i],Imb_180[i],Imb_179[i],Imb_178[i],Imb_177[i],Imb_176[i],Imb_175[i],Imb_174[i],Imb_173[i],Imb_172[i],Imb_171[i],Imb_170[i],Imb_169[i],Imb_168[i],Imb_167[i],Imb_166[i],Imb_165[i],Imb_164[i],Imb_163[i],Imb_162[i],Imb_161[i],Imb_160[i],Imb_159[i],Imb_158[i],Imb_157[i],Imb_156[i],Imb_155[i],Imb_154[i],Imb_153[i],Imb_152[i],Imb_151[i],Imb_150[i],Imb_149[i],Imb_148[i],Imb_147[i],Imb_146[i],Imb_145[i],Imb_144[i],Imb_143[i],Imb_142[i],Imb_141[i],Imb_140[i],Imb_139[i],Imb_138[i],Imb_137[i],Imb_136[i],Imb_135[i],Imb_134[i],Imb_133[i],Imb_132[i],Imb_131[i],Imb_130[i],Imb_129[i],Imb_128[i],Imb_127[i],Imb_126[i],Imb_125[i],Imb_124[i],Imb_123[i],Imb_122[i],Imb_121[i],Imb_120[i],Imb_119[i],Imb_118[i],Imb_117[i],Imb_116[i],Imb_115[i],Imb_114[i],Imb_113[i],Imb_112[i],Imb_111[i],Imb_110[i],Imb_109[i],Imb_108[i],Imb_107[i],Imb_106[i],Imb_105[i],Imb_104[i],Imb_103[i],Imb_102[i],Imb_101[i],Imb_100[i],Imb_99[i],Imb_98[i],Imb_97[i],Imb_96[i],Imb_95[i],Imb_94[i],Imb_93[i],Imb_92[i],Imb_91[i],Imb_90[i],Imb_89[i],Imb_88[i],Imb_87[i],Imb_86[i],Imb_85[i],Imb_84[i],Imb_83[i],Imb_82[i],Imb_81[i],Imb_80[i],Imb_79[i],Imb_78[i],Imb_77[i],Imb_76[i],Imb_75[i],Imb_74[i],Imb_73[i],Imb_72[i],Imb_71[i],Imb_70[i],Imb_69[i],Imb_68[i],Imb_67[i],Imb_66[i],Imb_65[i],Imb_64[i],Imb_63[i],Imb_62[i],Imb_61[i],Imb_60[i],Imb_59[i],Imb_58[i],Imb_57[i],Imb_56[i],Imb_55[i],Imb_54[i],Imb_53[i],Imb_52[i],Imb_51[i],Imb_50[i],Imb_49[i],Imb_48[i],Imb_47[i],Imb_46[i],Imb_45[i],Imb_44[i],Imb_43[i],Imb_42[i],Imb_41[i],Imb_40[i],Imb_39[i],Imb_38[i],Imb_37[i],Imb_36[i],Imb_35[i],Imb_34[i],Imb_33[i],Imb_32[i],Imb_31[i],Imb_30[i],Imb_29[i],Imb_28[i],Imb_27[i],Imb_26[i],Imb_25[i],Imb_24[i],Imb_23[i],Imb_22[i],Imb_21[i],Imb_20[i],Imb_19[i],Imb_18[i],Imb_17[i],Imb_16[i],Imb_15[i],Imb_14[i],Imb_13[i],Imb_12[i],Imb_11[i],Imb_10[i],Imb_9[i],Imb_8[i],Imb_7[i],Imb_6[i],Imb_5[i],Imb_4[i],Imb_3[i],Imb_2[i],Imb_1[i],Imb_0[i]}, S, E, Y[i]);
        end
    endgenerate
	
endmodule



///LargeMuX_made_using_for_generate_construct/////////
///Example MUX256to1_1bit_MUX/////////
module LargeMuX_withE(I, S, E, Y);
	parameter n = 8; //n
  	parameter twopn = 256;//two_power_n
  	input [n-1:0] S;
	input E;
  	input [twopn-1:0] I;
	output wire Y;
  
  	wire Ytemp;
  	wire [twopn-1:0] Dtemp;

  LargeDecoder_withE #(.n(n), .twopn(twopn)) inst1dec(S, E, Dtemp);
  	
  	generate
    	genvar i; // Generate variable for the loop

      for (i = 0; i < (twopn); i = i + 1) 
        begin
          bufif1 instauto(Ytemp, I[i], Dtemp[i]); 
        end
    endgenerate
  	
  	assign Y = (E==1'b1)?Ytemp:1'b0;   ///when disabled gives 0
//  assign Y = Ytemp;   ///when disabled gives floating
    
endmodule
  





///LargeDecoder_made_using_for_generate_construct/////////
//Example 8to256Decoder///
module LargeDecoder_withE(A, E, D);
	parameter n = 8; //n
  	parameter twopn = 256;//two_power_n
    input [n-1:0] A;
	input E;
	output wire [twopn-1:0] D;

  	generate
    	genvar i; // Generate variable for the loop

      for (i = 0; i < (twopn); i = i + 1) 
        begin
          assign D[i] = E & (A == i[n-1:0]);
        end
    endgenerate
    
endmodule