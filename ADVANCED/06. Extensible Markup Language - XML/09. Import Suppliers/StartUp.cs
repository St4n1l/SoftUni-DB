﻿using CarDealer.Data;
using CarDealer.DTOs.Import;
using CarDealer.Models;
using System.Xml.Serialization;

namespace CarDealer
{
    public class StartUp
    {
        public static void Main()
        {
            var context = new CarDealerContext();

            context.Database.EnsureDeleted();
            context.Database.EnsureCreated();

            string suppliersFilePath = @"../../../Datasets/suppliers.xml";
            string suppliersXml = File.ReadAllText(suppliersFilePath);
            string output = ImportSuppliers(context, suppliersXml);

            Console.WriteLine(output);
        }

        // This is a generic XML deserializer
        private static T Deserializer<T>(string inputXml, string rootName)
        {
            XmlRootAttribute root = new XmlRootAttribute(rootName);
            XmlSerializer serializer = new XmlSerializer(typeof(T), root);

            using StringReader reader = new StringReader(inputXml);

            T dtos = (T)serializer.Deserialize(reader);
            return dtos;
        }

        public static string ImportSuppliers(CarDealerContext context, string inputXml)
        {
            ImportSuppliersDto[] suppliersDtos = Deserializer<ImportSuppliersDto[]>(inputXml, "Suppliers");

            Supplier[] suppliers = suppliersDtos
                .Select(s => new Supplier()
                {
                    Name = s.Name,
                    IsImporter = s.IsImporter
                })
                .ToArray();

            context.Suppliers.AddRange(suppliers);
            context.SaveChanges();

            return $"Successfully imported {suppliers.Count()}";
        }
    }
}