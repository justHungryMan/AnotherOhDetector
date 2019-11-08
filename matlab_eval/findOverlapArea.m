function Area = findOverlapArea(BBox1, BBox2)

r1.leftTopX = BBox1(1);
r1.leftTopY = BBox1(2);
r1.rightBotX = BBox1(3)+BBox1(1);
r1.rightBotY = BBox1(4)+BBox1(2);

r2.leftTopX = BBox2(1);
r2.leftTopY = BBox2(2);
r2.rightBotX = BBox2(3)+BBox2(1);
r2.rightBotY = BBox2(4)+BBox2(2);

left_top_X = max(r1.leftTopX, r2.leftTopX);
left_top_Y = max(r1.leftTopY, r2.leftTopY);
Right_Bot_X = min(r1.rightBotX, r2.rightBotX);
Right_Bot_Y = min(r1.rightBotY, r2.rightBotY);

W = Right_Bot_X - left_top_X;
H = Right_Bot_Y - left_top_Y;

Area = W * H;
if(Area < 0)
    Area = 0;
end


end